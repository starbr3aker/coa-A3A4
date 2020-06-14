`timescale 1ns/1ns
/* 
Module for reading and writing to main memory, stored as data.mem
*/

module read_data_memory(
    output reg [31:0] read_data,//The data read from the main memory (from the given address)
    input  [31:0] address, write_data,//The ADDRESS and WRITE_DATA are inputs to this module after ALU processing
    input [5:0] opcode,
    input [4:0] rs,
    input MemRead,MemWrite,MemToReg//Read and Write signals to main memory
);
	
    reg [31:0] data_mem [255:0];   //The contents of the main memory
    reg [31:0] reg_mem [31:0];

    always @(address, MemWrite) begin
        if(MemWrite) begin
            $readmemb("data.mem", data_mem, 255 ,0); // adjust according to the number of entries in data.mem
            if(opcode == 6'h28) begin
                data_mem[address][7:0] = write_data[7:0];
            end 
            else if(opcode == 6'h29) begin
                data_mem[address][15:0] = write_data[15:0];
            end
            else begin
                data_mem[address] = write_data;
            end
            // Write the updated contents back to the data_mem file
            $writememb("data.mem", data_mem);
        end
    end
	
    always @(address) begin
        $readmemb("data.mem", data_mem, 255 ,0); //adjust according to the number of entries in data.mem
        $readmemb("registers.mem", reg_mem, 31, 0); 
        if(MemRead) begin
            read_data = data_mem[address];
        end
        if(MemToReg) begin
            reg_mem[rs] = read_data;
            $writememb("registers.mem", reg_mem);
        end
    end	

endmodule

module read_data_memory_tb();
    wire [31:0] read_data;
    reg  [31:0] address, write_data;
    reg [5:0] opcode;
    reg MemRead,MemWrite;

    read_data_memory datamem(
        .read_data(read_data),
        .address(address),
        .write_data(write_data),
        .opcode(opcode),
        .MemRead(MemRead),
        .MemWrite(MemWrite)
    );

    initial begin
        MemWrite = 1'b1;
        MemRead = 1'b0;

        //write halfword
        opcode = 6'h28;
        write_data = 32'd253;
        address = 32'd0;
        #10;

        //write word
        opcode = 6'h29;
        write_data = 32'd1011;
        address = 32'd13;
        #10;

        // read word
        MemWrite = 1'b0;
        MemRead = 1'b1;
        address = 32'd7;
        #10;
    end


    initial begin
        $dumpfile("read_data_memory.vcd"); 
        $dumpvars(0, read_data_memory_tb);
    end

endmodule
