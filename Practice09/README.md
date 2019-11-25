# Lab 09

## 실습 내용

### **적외선 컨트롤러**

: 적외선 컨트롤러(IR Controller) : 리모컨. 적외선 발광 다이오드로 적외선 송신, FPGA에서 수신


### **적외선 신호 송수신**

![](https://github.com/choihj0202/LogicDesign/blob/master/Practice09/figs/waveform.PNG)

![](https://github.com/choihj0202/LogicDesign/blob/master/Practice09/figs/waveform2.PNG)

![](https://github.com/choihj0202/LogicDesign/blob/master/Practice09/figs/waveform1.PNG)

: (사진 1)

: 1에서 LEADER CODE(ir_rx) 수신. 실험 환경에 맞춰 ir_rxb 뒤집음

: 2에서 seq_rx = 2'b11일 때 cnt_h ++, 8000 이상 되면 LEADER CODE -> DATA CODE

: 3에서 seq_rx = 2'b00일 때 cnt_l ++

: 4에서 DATA CODE 수신 시 seq_rx = 2'b01(사진 2)일 때 cnt32 ++. 6'd32가 될 때까지

: 5에서 (사진 3) cnt32 = 6'd32일 때 DATA CODE -> COMPLETE (그 때의 data와 동일한 o_data 출력) -> IDLE (cnt32 = 6'd0) -> LEADER CODE -> (반복)


### **FPGA 실습**

![](https://github.com/choihj0202/LogicDesign/blob/master/Practice09/figs/FPGA.jpg)

: 리모컨의 OK 버튼을 누른 모습. 