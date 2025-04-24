module test_cpu();

    reg reset;
    reg clk;

    // Clock generation
    parameter CLOCK_PERIOD = 10;
    initial clk = 1;
    always #(CLOCK_PERIOD / 2) clk = ~clk;

    // Instantiate CPU
    wire             Device_Read;
    wire             Device_Write;
    wire [32 - 1: 0] MemBus_Address;
    wire [32 - 1: 0] Device_Read_Data;
    wire [32 - 1: 0] MemBus_Write_Data;

    CPU cpu1(
        .reset             (reset             ),
        .clk               (clk               ),
        .Device_Read       (Device_Read       ),
        .Device_Write      (Device_Write      ),
        .MemBus_Address    (MemBus_Address    ),
        .Device_Read_Data  (Device_Read_Data  ),
        .MemBus_Write_Data (MemBus_Write_Data )
    );

    // Test status and statistics
    parameter TOTAL_CYCLES = 60;

    integer cycle_count;
    integer total_tests;
    integer passed_tests;
    integer failed_tests;

    // File reading related
    parameter MAX_LINE_LENGTH = 200;

    integer fd;
    integer scan_count;
    reg [MAX_LINE_LENGTH * 8 - 1: 0] line;

    integer check_cycle;
    reg [32 - 1: 0] check_type;
    reg [32 - 1: 0] check_addr;
    reg [32 - 1: 0] expected_value;
    reg [32 - 1: 0] actual_value;

    // Test sequence
    initial begin
        // Initialize
        cycle_count = 0;
        total_tests = 0;
        passed_tests = 0;
        failed_tests = 0;

        // Monitor key signals
        $monitor("Time=%0t Cycle=%0d PC=%h Instruction=%h",
                 $time, cycle_count, cpu1.PC, cpu1.Instruction);

        // Start testing
        reset = 1;
        #(CLOCK_PERIOD)
        reset = 0;

        // Wait for test completion
        #(CLOCK_PERIOD * (TOTAL_CYCLES + 1))

        // Display test statistics
        $display("\n========== Test Statistics ==========");
        $display("Total Tests: %0d", total_tests);
        $display("Passed: %0d", passed_tests);
        $display("Failed: %0d", failed_tests);
        $display("Pass Rate: %0.2f%%", (passed_tests * 100.0) / total_tests);
        $display("=====================================\n");

        $finish;
    end

    // Check at each clock rising edge
    always @(posedge clk) begin
        if (!reset) begin
            check_cycle_values();
            cycle_count = cycle_count + 1;
        end
    end

    // Check all expected values for current cycle
    task check_cycle_values();
        begin
            fd = $fopen("../../../../../cpu/testbench/checkpoints.txt", "r");
            if (fd == 0) begin
                $display("Error: Cannot open file");
                $finish;
            end

            while (!$feof(fd)) begin
                // Parse one line of test data
                if ($fgets(line, fd)) begin
                    scan_count = $sscanf(line, "%d %s %h %h", check_cycle, check_type, check_addr, expected_value);
                    // Skip invalid lines
                    if (scan_count == 4) begin
                        // Only check values for current cycle
                        if (check_cycle == cycle_count) begin
                            check_value();
                            total_tests = total_tests + 1;
                        end
                    end
                end
            end

            $fclose(fd);
        end
    endtask

    task check_value();
        case (check_type)
            "pc": begin
                actual_value = cpu1.PC;
                if (actual_value !== expected_value) begin
                    $display("Error[Cycle%0d]: PC value mismatch. Expected=%h, Actual=%h",
                        cycle_count, expected_value, actual_value);
                    failed_tests = failed_tests + 1;
                end
                else begin
                    passed_tests = passed_tests + 1;
                end
            end
            "reg": begin
                actual_value = cpu1.register_file1.RF_data[check_addr];
                if (actual_value !== expected_value) begin
                    $display("Error[Cycle%0d]: Register $%0d value mismatch. Expected=%h, Actual=%h",
                        cycle_count, check_addr, expected_value, actual_value);
                    failed_tests = failed_tests + 1;
                end
                else begin
                    passed_tests = passed_tests + 1;
                end
            end
            "mem": begin
                actual_value = cpu1.data_memory1.RAM_data[check_addr / 4];
                if (actual_value !== expected_value) begin
                    $display("Error[Cycle%0d]: Memory address %h value mismatch. Expected=%h, Actual=%h",
                        cycle_count, check_addr, expected_value, actual_value);
                    failed_tests = failed_tests + 1;
                end
                else begin
                    passed_tests = passed_tests + 1;
                end
            end
            default: begin
                $display("Error[Cycle%0d]: Unknown check type %s", cycle_count, check_type);
                failed_tests = failed_tests + 1;
            end
        endcase
    endtask

endmodule
