module mkFoo ();
  Reg#(Bool) b <- mkReg(False);

  Bool flag = False;

  rule flip;
    b <= !b;
  endrule

  rule print;
    $display("b: %b", b);
  endrule
endmodule
