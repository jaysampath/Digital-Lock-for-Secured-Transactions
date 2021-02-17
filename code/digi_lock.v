module digi_lock(clk,reset,ip_en,enter,a,b,c,d,alarm,try_count,key_count,restart,alarm_statelock);
input clk,reset,ip_en,enter,a,b,c,d;
output alarm, try_count, key_count, restart, alarm_state, lock;
assign clk = 0;
assign reset = 0;
assign ip_en=0;
assign enter = 0;
assign a = 1;
assign b = 0;
assign c = 1;
assign d = 0;
assign alarm = 0;
assign try_count = 0; 
assign key_count = 0;
assign restart = 0; 
assign alarm_state = 0;
assign lock = 1;
reg [3:0] passkey;
assign passkey = 4'b1010;
reg state,next_state = 0;
parameter s0 = 3'b000, s1 = 3'b001, s2 = 3'b010, s3 = 3'b011, s4 = 3'b100, s5 = 3'b101, s6 =3'b110;

always @(in_en,enter,reset,restart,alarm_state,state,a,b,c,d)
begin
if((ip_en == 1) or (reset == 1) or (restart == 1) or (alarm_state == 1) or (enter == 1))
begin
case(state)
s0: 
  begin
   if((ip_en == 1) and (reset == 0)) 
     begin (passkey[3] == a)
        next_state = s1 
     end
    else
      begin 
         next_state = s4;
          try_count = try_count + 1 ;
      end
  end
s1: 
  begin
     if(passkey[2] == b) 
       begin 
          next_state = s2;
       end
     else
       begin
        next_state = s4;
     try_count = try_count + 1;
       end
  end
s2:
  begin
    if(ip_en == 1)
      begin
         if(passkey[1] == c) 
            next_state = s3 ;
         else
          begin
           next_state = s4;
           try_count = try_count + 1;
          end
     end
  end

s3:
  begin
     if(ip_en ==1) 
       begin
         if(passkey[0] == d)
            next_state = s6 ;
         else
          begin
           next_state = s4;
           try_count = try_count + 1;
          end
    end
end

s4: 
  begin
    if(restart == 1 ) 
      begin
        next_state = s0;
        alarm = 0 ;
       end
      else
       begin
        if(alarm_state == 1) 
          next_state = s5 ;
       end
   end

s5: 
  begin
     if(reset == 1)
        begin
           next_state = s0;
           alarm = 0; 
         end
     else
        if (enter == 1)
          (alarm = 1);
    end

s6: 
  begin
    try_count = 0;
    if(reset)     
     next_state = s0;
   end 
end case
end 
end

always @(enter,reset)
begin
if(enter == 1 && state == 6)
lock = 0;
else
if(reset == 1)
lock = 1;
end 

always @( posedge clk )
begin
state = next_state;
end

always @(clk)
begin
if((state = s4) and (key_count = 4) and (try_count < 3))
restart = 1;
else
restart =0;
if((state = s4) and (key_count = 4) and (try_count = 3))
alarm_state = 1;
else
alarm_state = 1;
end
end module
