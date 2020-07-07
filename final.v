module final(clk, sbu, lbu, ch_end, st_end, reset, col, row, seven);
input clk, sbu, lbu, ch_end, st_end, reset;
output [6:0] seven;

output [7:0] col,row;
parameter [1:0] no=2'b00, sh=2'b01, lo=2'b10;

wire div_clk;

clk_div_dot_matrix
(
	.clk(clk),
	.rst(reset),
	.div_clk(div_clk)
);

circle_dis( .clk(clk),.div_clk(div_clk), .ch(code), .st_end(st_end), .ch_end(call_cir), .col(col), .row(row));
segdisplay(.bu(bu), .seg_out(seven));

reg flag=1'b0, flag2=1'b0;
reg[24:0] delay=25'd0, delay2=25'd0;
reg[1:0] v1=no, v2=no, v3=no, v4=no, v5=no, bu;
reg[5:0] code;
reg f=0, f2=0, call_cir=0;

always@(posedge clk)
begin
	if(!reset)
	begin
		v1=no; v2=no; v3=no; v4=no; v5=no;
		code = 37;
		flag = 1'b0;
		delay = 25'd0;
	end
	else if(!ch_end || f2)
	begin
		if((!ch_end)&&(!flag2))
		begin
			flag2 = 1'b1;
		end
		else if(flag2)
		begin
			if(delay2 == 25'd1000000)
			begin
				flag2 = 1'b0;
				delay2 = 25'd0;
				f2 = 1;
			end
			else
				delay2 = delay2 + 1'b1;
		end
		else if(f2)
		begin
		case({v1,v2,v3,v4,v5})
			10'b01_10_00_00_00:
			code = 6'd1;
			10'b10_01_01_01_00:
			code = 6'd2;
			10'b10_01_10_01_00:
			code = 3;
			10'b10_01_01_00_00:
			code = 4;
			10'b01_00_00_00_00:
			code = 5;
			10'b01_01_10_01_00:
			code = 6;
			10'b10_10_01_00_00:
			code = 7;
			10'b01_01_01_01_00:
			code = 8;
			10'b01_01_00_00_00:
			code = 9;
			10'b01_10_10_10_00:
			code = 10;
			10'b10_01_10_00_00:
			code = 11;
			10'b01_10_01_01_00:
			code = 12;
			10'b10_10_00_00_00:
			code = 13;
			//N
			10'b10_01_00_00_00:
			code = 14;
			10'b10_10_10_00_00:
			code = 15;
			10'b01_10_10_01_00:
			code = 16;
			10'b10_10_01_10_00:
			code = 17;
			10'b01_10_01_00_00:
			code = 18;
			10'b01_01_01_00_00:
			code = 19;
			10'b10_00_00_00_00:
			code = 20;
			//U
			10'b01_01_10_00_00:
			code = 21;
			10'b01_01_01_10_00:
			code = 22;
			10'b01_10_10_00_00:
			code = 23;
			10'b10_01_01_10_00:
			code = 24;
			10'b10_01_10_10_00:
			code = 25;
			10'b10_10_01_01_00:
			code = 26;
			//numbers
			10'b01_10_10_10_10:
			code = 27;
			10'b01_01_10_10_10:
			code= 28;
			10'b01_01_01_10_10:
			code = 29;
			10'b01_01_01_01_10:
			code = 30;
			10'b01_01_01_01_01:
			code = 31;
			10'b10_01_01_01_01:
			code = 32;
			10'b10_10_01_01_01:
			code = 33;
			10'b10_10_10_01_01:
			code = 34;
			10'b10_10_10_10_01:
			code = 35;
			10'b10_10_10_10_10:
			code = 36;
			default:
			code = 0;
		endcase
		call_cir = 1;
		f2 = 0;
		v1=no; v2=no; v3=no; v4=no; v5=no;
		end
		else;
	end
	else
	begin
		call_cir = 0;
		//identify short or long
		if((!sbu)&&(!flag))
		begin
			flag = 1'b1;
			bu = 2'b01;
		end
		else if((!lbu)&&(!flag))
		begin
			flag = 1'b1;
			bu = 2'b10;
		end
		//assign value to v1~v5
		else if(flag)
		begin
			if(delay == 25'd1000000)
			begin
				flag = 1'b0;
				delay = 25'd0;
				f = 1;
			end
			else
				delay = delay + 1'b1;
		end
		else if(f)
		begin
			f = 0;
			if(v1 == no) v1 = bu;
			else if(v2 == no) v2 = bu;
			else if(v3 == no) v3 = bu;
			else if(v4 == no) v4 = bu;
			else if(v5 == no) v5 = bu;
			else;
		end
		else;
	end
end
endmodule


module segdisplay(bu, seg_out);
input [1:0] bu;
output [6:0] seg_out;

reg [6:0] seg_out;

always @ (bu)
begin
	case(bu)
		2'b10:begin 		// L
			seg_out=7'b1000111;
		end

		2'b01:begin 		// S
			seg_out=7'b0010010;
		end

		default:begin		// Error don'tshow
			seg_out=7'b1111111;
		end
	endcase
end
endmodule


module circle_dis(clk, div_clk, ch, st_end, ch_end, col, row);
input [5:0] ch; //letter
input clk, st_end, ch_end, div_clk; 

output [7:0]col,row;
parameter store=0, cir=1;

reg [1:0] currentstate=store;
reg [5:0] out;
reg [5:0] word[0:20]; //word
reg [4:0] count=0;
reg [4:0] num;
reg flag=1'b0, conti=0;
reg [24:0] delay=25'd0;

reg [31:0] del;

reg f=0;

dot_matrix_dis(.clk(div_clk), .word(out), .col(col), .row(row));

always@(posedge clk)
begin
if(ch_end)
begin
	conti = 0;
	if(currentstate==cir && ch)
	begin
		count = 0;
		num = 0;
		word[count] = ch;
		out = word[count];
		count = count+1;
		currentstate = store;
	end
	else if(currentstate == store && ch)
	begin	
		word[count] = ch;
		out = word[count];
		count = count+1;
	end
	else;
end
else if(!st_end || conti)
begin
	currentstate=cir;
	conti = 1;
	if(del==32'd50000000)
	begin
		del=32'd0;
		out = word[num];
		num = (num+1 < count)?(num+1):(0);
	end
	else
		del = del+32'd1;
end
else;
end
endmodule

module dot_matrix_dis(clk,word,col,row);
input clk;
input [5:0]word;
output [7:0]col,row;
reg [7:0]col,row;
reg [2:0]count;

always @ (posedge clk)
begin
count<=count+3'b001;
	case(word)
	6'd1:begin
	case(count)//A
		3'b000:begin col=8'b00111000; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01000100; row=8'b11101111; end
		3'b100:begin col=8'b01111100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b01000100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd2:begin
	case(count)//B
		3'b000:begin col=8'b01111000; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01111000; row=8'b11101111; end
		3'b100:begin col=8'b01000100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b01111000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd3:begin
	case(count)//C
		3'b000:begin col=8'b00111000; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000000; row=8'b11011111; end
		3'b011:begin col=8'b01000000; row=8'b11101111; end
		3'b100:begin col=8'b01000000; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b00111000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd4:begin
	case(count)//D
		3'b000:begin col=8'b01111000; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01000100; row=8'b11101111; end
		3'b100:begin col=8'b01000100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b01111000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd5:begin
	case(count)//E
		3'b000:begin col=8'b01111100; row=8'b01111111; end
		3'b001:begin col=8'b01000000; row=8'b10111111; end
		3'b010:begin col=8'b01000000; row=8'b11011111; end
		3'b011:begin col=8'b01111000; row=8'b11101111; end
		3'b100:begin col=8'b01000000; row=8'b11110111; end
		3'b101:begin col=8'b01000000; row=8'b11111011; end
		3'b110:begin col=8'b01111100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd6:begin
	case(count)  //F
		3'b000:begin col=8'b01111100; row=8'b01111111; end
		3'b001:begin col=8'b01000000; row=8'b10111111; end
		3'b010:begin col=8'b01000000; row=8'b11011111; end
		3'b011:begin col=8'b01111000; row=8'b11101111; end
		3'b100:begin col=8'b01000000; row=8'b11110111; end
		3'b101:begin col=8'b01000000; row=8'b11111011; end
		3'b110:begin col=8'b01000000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd7:begin
	case(count)  //G
		3'b000:begin col=8'b00111000; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000000; row=8'b11011111; end
		3'b011:begin col=8'b01000000; row=8'b11101111; end
		3'b100:begin col=8'b01011100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b00111000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd8:begin
	case(count)  //H
		3'b000:begin col=8'b01000100; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01111100; row=8'b11101111; end
		3'b100:begin col=8'b01000100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b01000100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd9:begin
	case(count)  //I
		3'b000:begin col=8'b00111000; row=8'b01111111; end
		3'b001:begin col=8'b00010000; row=8'b10111111; end
		3'b010:begin col=8'b00010000; row=8'b11011111; end
		3'b011:begin col=8'b00010000; row=8'b11101111; end
		3'b100:begin col=8'b00010000; row=8'b11110111; end
		3'b101:begin col=8'b00010000; row=8'b11111011; end
		3'b110:begin col=8'b00111000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd10:begin
	case(count)  //J
		3'b000:begin col=8'b00000100; row=8'b01111111; end
		3'b001:begin col=8'b00000100; row=8'b10111111; end
		3'b010:begin col=8'b00000100; row=8'b11011111; end
		3'b011:begin col=8'b00000100; row=8'b11101111; end
		3'b100:begin col=8'b01000100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b00111000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd11:begin//K
	case(count)
		3'b000:begin col=8'b01000100; row=8'b01111111; end
		3'b001:begin col=8'b01001000; row=8'b10111111; end
		3'b010:begin col=8'b01010000; row=8'b11011111; end
		3'b011:begin col=8'b01100000; row=8'b11101111; end
		3'b100:begin col=8'b01010000; row=8'b11110111; end
		3'b101:begin col=8'b01001000; row=8'b11111011; end
		3'b110:begin col=8'b01000100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd12:
	begin //L
	case(count)
		3'b000:begin col=8'b01000000; row=8'b01111111; end
		3'b001:begin col=8'b01000000; row=8'b10111111; end
		3'b010:begin col=8'b01000000; row=8'b11011111; end
		3'b011:begin col=8'b01000000; row=8'b11101111; end
		3'b100:begin col=8'b01000000; row=8'b11110111; end
		3'b101:begin col=8'b01000000; row=8'b11111011; end
		3'b110:begin col=8'b01111110; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd13:begin //M
	case(count)
		3'b000:begin col=8'b01000100; row=8'b01111111; end
		3'b001:begin col=8'b01101100; row=8'b10111111; end
		3'b010:begin col=8'b01010100; row=8'b11011111; end
		3'b011:begin col=8'b01000100; row=8'b11101111; end
		3'b100:begin col=8'b01000100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b01000100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd14:begin //N
	case(count)
		3'b000:begin col=8'b01000100; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01100100; row=8'b11011111; end
		3'b011:begin col=8'b01010100; row=8'b11101111; end
		3'b100:begin col=8'b01001100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b01000100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd15:begin //O
	case(count)
		3'b000:begin col=8'b00111000; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01000100; row=8'b11101111; end
		3'b100:begin col=8'b01000100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b00111000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd16:begin //P
	case(count)
		3'b000:begin col=8'b01111000; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01000100; row=8'b11101111; end
		3'b100:begin col=8'b01111000; row=8'b11110111; end
		3'b101:begin col=8'b01000000; row=8'b11111011; end
		3'b110:begin col=8'b01000000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd17:begin //Q
	case(count)
		3'b000:begin col=8'b00111000; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01000100; row=8'b11101111; end
		3'b100:begin col=8'b01010100; row=8'b11110111; end
		3'b101:begin col=8'b01001100; row=8'b11111011; end
		3'b110:begin col=8'b00111100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd18:begin //R
	case(count)
		3'b000:begin col=8'b01111000; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01000100; row=8'b11101111; end
		3'b100:begin col=8'b01111000; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b01000100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd19:begin //S
	case(count)
		3'b000:begin col=8'b00111000; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000000; row=8'b11011111; end
		3'b011:begin col=8'b00111000; row=8'b11101111; end
		3'b100:begin col=8'b00000100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b00111000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd20:begin //T
	case(count)
		3'b000:begin col=8'b01111100; row=8'b01111111; end
		3'b001:begin col=8'b00010000; row=8'b10111111; end
		3'b010:begin col=8'b00010000; row=8'b11011111; end
		3'b011:begin col=8'b00010000; row=8'b11101111; end
		3'b100:begin col=8'b00010000; row=8'b11110111; end
		3'b101:begin col=8'b00010000; row=8'b11111011; end
		3'b110:begin col=8'b00010000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd21:begin //U
	case(count)
		3'b000:begin col=8'b01000100; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01000100; row=8'b11101111; end
		3'b100:begin col=8'b01000100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b00111000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd22:begin //V
	case(count)
		3'b000:begin col=8'b01000100; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01000100; row=8'b11101111; end
		3'b100:begin col=8'b01000100; row=8'b11110111; end
		3'b101:begin col=8'b00101000; row=8'b11111011; end
		3'b110:begin col=8'b00010000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd23:begin //W
	case(count)
		3'b000:begin col=8'b01000100; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01000100; row=8'b11101111; end
		3'b100:begin col=8'b01010100; row=8'b11110111; end
		3'b101:begin col=8'b01101100; row=8'b11111011; end
		3'b110:begin col=8'b01000100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd24:begin //X
	case(count)
		3'b000:begin col=8'b01000100; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b00101000; row=8'b11011111; end
		3'b011:begin col=8'b00010000; row=8'b11101111; end
		3'b100:begin col=8'b00101000; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b01000100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd25:begin //Y
	case(count)
		3'b000:begin col=8'b01000100; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b00101000; row=8'b11101111; end
		3'b100:begin col=8'b00010000; row=8'b11110111; end
		3'b101:begin col=8'b00010000; row=8'b11111011; end
		3'b110:begin col=8'b00010000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd26:begin //Z
	case(count)
		3'b000:begin col=8'b01111100; row=8'b01111111; end
		3'b001:begin col=8'b00000100; row=8'b10111111; end
		3'b010:begin col=8'b00001000; row=8'b11011111; end
		3'b011:begin col=8'b00010000; row=8'b11101111; end
		3'b100:begin col=8'b00100000; row=8'b11110111; end
		3'b101:begin col=8'b01000000; row=8'b11111011; end
		3'b110:begin col=8'b01111100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd27:begin
	case(count)
		3'b000:begin col=8'b00010000; row=8'b01111111; end
		3'b001:begin col=8'b00110000; row=8'b10111111; end
		3'b010:begin col=8'b00010000; row=8'b11011111; end
		3'b011:begin col=8'b00010000; row=8'b11101111; end
		3'b100:begin col=8'b00010000; row=8'b11110111; end
		3'b101:begin col=8'b00010000; row=8'b11111011; end
		3'b110:begin col=8'b00010000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd28:begin
	case(count)
		3'b000:begin col=8'b01111100; row=8'b01111111; end
		3'b001:begin col=8'b00000100; row=8'b10111111; end
		3'b010:begin col=8'b00000100; row=8'b11011111; end
		3'b011:begin col=8'b01111100; row=8'b11101111; end
		3'b100:begin col=8'b01000000; row=8'b11110111; end
		3'b101:begin col=8'b01000000; row=8'b11111011; end
		3'b110:begin col=8'b01111100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd29:begin
	case(count)
		3'b000:begin col=8'b01111100; row=8'b01111111; end
		3'b001:begin col=8'b00000100; row=8'b10111111; end
		3'b010:begin col=8'b00000100; row=8'b11011111; end
		3'b011:begin col=8'b00111100; row=8'b11101111; end
		3'b100:begin col=8'b00000100; row=8'b11110111; end
		3'b101:begin col=8'b00000100; row=8'b11111011; end
		3'b110:begin col=8'b01111100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd30:begin
	case(count)
		3'b000:begin col=8'b01000100; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01111100; row=8'b11101111; end
		3'b100:begin col=8'b00000100; row=8'b11110111; end
		3'b101:begin col=8'b00000100; row=8'b11111011; end
		3'b110:begin col=8'b00000100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd31:begin
	case(count)
		3'b000:begin col=8'b01111100; row=8'b01111111; end
		3'b001:begin col=8'b01000000; row=8'b10111111; end
		3'b010:begin col=8'b01000000; row=8'b11011111; end
		3'b011:begin col=8'b01111100; row=8'b11101111; end
		3'b100:begin col=8'b00000100; row=8'b11110111; end
		3'b101:begin col=8'b00000100; row=8'b11111011; end
		3'b110:begin col=8'b01111100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd32:begin
	case(count)
		3'b000:begin col=8'b01111100; row=8'b01111111; end
		3'b001:begin col=8'b01000000; row=8'b10111111; end
		3'b010:begin col=8'b01000000; row=8'b11011111; end
		3'b011:begin col=8'b01111100; row=8'b11101111; end
		3'b100:begin col=8'b01000100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b01111100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd33:begin
	case(count)
		3'b000:begin col=8'b01111100; row=8'b01111111; end
		3'b001:begin col=8'b00000100; row=8'b10111111; end
		3'b010:begin col=8'b00000100; row=8'b11011111; end
		3'b011:begin col=8'b00001000; row=8'b11101111; end
		3'b100:begin col=8'b00010000; row=8'b11110111; end
		3'b101:begin col=8'b00010000; row=8'b11111011; end
		3'b110:begin col=8'b00010000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd34:begin
	case(count)
		3'b000:begin col=8'b01111100; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01111100; row=8'b11101111; end
		3'b100:begin col=8'b01000100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b01111100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd35:begin
	case(count)
		3'b000:begin col=8'b01111100; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01111100; row=8'b11101111; end
		3'b100:begin col=8'b00000100; row=8'b11110111; end
		3'b101:begin col=8'b00000100; row=8'b11111011; end
		3'b110:begin col=8'b01111100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	6'd36:begin
	case(count)
		3'b000:begin col=8'b01111100; row=8'b01111111; end
		3'b001:begin col=8'b01000100; row=8'b10111111; end
		3'b010:begin col=8'b01000100; row=8'b11011111; end
		3'b011:begin col=8'b01000100; row=8'b11101111; end
		3'b100:begin col=8'b01000100; row=8'b11110111; end
		3'b101:begin col=8'b01000100; row=8'b11111011; end
		3'b110:begin col=8'b01111100; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
	default:begin
	case(count)
		3'b000:begin col=8'b00000000; row=8'b01111111; end
		3'b001:begin col=8'b00000000; row=8'b10111111; end
		3'b010:begin col=8'b00000000; row=8'b11011111; end
		3'b011:begin col=8'b00000000; row=8'b11101111; end
		3'b100:begin col=8'b00000000; row=8'b11110111; end
		3'b101:begin col=8'b00000000; row=8'b11111011; end
		3'b110:begin col=8'b00000000; row=8'b11111101; end
		3'b111:begin col=8'b00000000; row=8'b11111110; end
		endcase
	end
endcase
end
endmodule

`define Timedot 32'd100

module clk_div_dot_matrix(clk,rst,div_clk);
input clk,rst;
output div_clk;

reg div_clk;
reg [31:0] count;

always @(posedge clk)
begin
	if(!rst)
	begin
		count <= 32'd0;
		div_clk <= 1'b0;
	end
	else
	begin
		if(count == `Timedot)
		begin
			count <= 32'd0;
			div_clk <= ~div_clk;
		end
		else
		begin
			count <= count + 32'd1;
		end
	end
end
endmodule




