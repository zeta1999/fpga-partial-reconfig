// Copyright (c) 2001-2018 Intel Corporation
//  
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//  
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//  
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

`timescale 1 ps / 1 ps
`default_nettype none

// This module acts as the persona top level wrapper to the pr core
// For this instance it is the basic arithmetic persona.
// NOTE ///////////////////////////////////////////////////////////////////
// Note that subsequent writes to key persona registers will require a 
// cycle delay after wait request goes low in order for correct values
// to be reported.
///////////////////////////////////////////////////////////////////////////
module basic_arithmetic_persona_top 
(
   input wire           pr_region_clk , 
   input wire           pr_logic_rst , 

   // Signaltap Interface
   input wire           tck ,
   input wire           tms ,
   input wire           tdi ,
   input wire           vir_tdi ,
   input wire           ena ,
   output wire          tdo ,
   // DDR4 interface
   input wire           emif_usr_clk ,
   input wire           emif_usr_rst_n ,
   input wire           emif_avmm_waitrequest , 
   input wire [511:0]   emif_avmm_readdata , 
   input wire           emif_avmm_readdatavalid , 
   output reg [6:0]     emif_avmm_burstcount , 
   output reg [511:0]   emif_avmm_writedata , 
   output reg [24:0]    emif_avmm_address , 
   output reg           emif_avmm_write , 
   output reg           emif_avmm_read , 
   output reg [63:0]    emif_avmm_byteenable , 

   input wire           pr_handshake_start_req ,
   output reg           pr_handshake_start_ack ,
   input wire           pr_handshake_stop_req ,
   output reg           pr_handshake_stop_ack ,
   output wire          freeze_pr_region_avmm ,

   // AVMM interface
   output reg           pr_region_avmm_waitrequest , 
   output reg [31:0]    pr_region_avmm_readdata , 
   output reg           pr_region_avmm_readdatavalid, 
   input wire [0:0]     pr_region_avmm_burstcount , 
   input wire [31:0]    pr_region_avmm_writedata , 
   input wire [15:0]    pr_region_avmm_address , 
   input wire           pr_region_avmm_write , 
   input wire           pr_region_avmm_read , 
   input wire [3:0]     pr_region_avmm_byteenable 
);

   always_ff @(posedge pr_region_clk) begin
         pr_handshake_start_ack <=1'b0;
         pr_handshake_stop_ack <=1'b0;
         if (  pr_handshake_start_req == 1'b0 ) begin
            pr_handshake_start_ack <= 1'b1;
         end
         // Active high SW reset
         if (  pr_handshake_stop_req == 1'b1 ) begin
            pr_handshake_stop_ack <=1'b1;
         end
   end
   
   assign freeze_pr_region_avmm = 1'b0;

    // PR Logic instantiation
    //
   basic_arithmetic_persona u_pr_core
   (
      .pr_region_clk                    ( pr_region_clk ),
      .pr_logic_rst                     ( pr_logic_rst ),
      // DDR4 interface
      .emif_usr_clk                     ( emif_usr_clk ) ,
      .emif_usr_rst_n                   ( emif_usr_rst_n ) ,  
      .emif_avmm_waitrequest            ( emif_avmm_waitrequest ),
      .emif_avmm_readdata               ( emif_avmm_readdata ),
      .emif_avmm_readdatavalid          ( emif_avmm_readdatavalid ),
      .emif_avmm_burstcount             ( emif_avmm_burstcount ),
      .emif_avmm_writedata              ( emif_avmm_writedata ),
      .emif_avmm_address                ( emif_avmm_address ),
      .emif_avmm_write                  ( emif_avmm_write ),
      .emif_avmm_read                   ( emif_avmm_read ),
      .emif_avmm_byteenable             ( emif_avmm_byteenable ),
      // AVMM interface
      .pr_region_avmm_waitrequest       ( pr_region_avmm_waitrequest ),
      .pr_region_avmm_readdata          ( pr_region_avmm_readdata ),
      .pr_region_avmm_readdatavalid     ( pr_region_avmm_readdatavalid ),
      .pr_region_avmm_burstcount        ( pr_region_avmm_burstcount ),
      .pr_region_avmm_writedata         ( pr_region_avmm_writedata),
      .pr_region_avmm_address           ( pr_region_avmm_address[13:0] ),
      .pr_region_avmm_write             ( pr_region_avmm_write ),
      .pr_region_avmm_read              ( pr_region_avmm_read ),
      .pr_region_avmm_byteenable        ( pr_region_avmm_byteenable )
       
   );


endmodule
