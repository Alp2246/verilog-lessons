// sohbet fsmd gelişmiş örnekler euclid gcd greatest common divisor uygulaması
// euclid GCD Greatest common divisior algoritması ile iki sayının en büyük ortak enob hesaplayan bir fsmd tasarımı yapacağız
// böylece kıyaslama döngü mantığı veri kontrolü gibi fakrlı mekanızmaları tek bir tasarımda nasıl birleştiridğimizi göreceğiz

// Euclid GCD Algoritması
///euclid algoritmasına göre iki sayının gcdsi şu prensibe dayanır
// gcd(a,b) = GCD(b,a mod b) (b =eşit 0 iken)
// b = 0 ise gcd(a,0) = a

// akış pseudocode:

while ( b != 0) {
    temp = a mod b;
    a = b;
    b = temp;
}
// a sonuc oldu 

// bu işlemi saatli adımlar abölersek her clockta bir mod atmaa ypaılabilir.

// FSMD tasarım planı

// data path
// registerlar regA , regB 16 bit varsayalım
// modül a mod b işlemini yapacak bir modül fpga 'de normalde bölme mod çok lut harcar veya dsp blokları gerekir küçük bit genişliğinde lut tabanlı mod da yapılabilir basitlik adına combinational mod diyelim

// FSM (control path):

// durumlar ıdle calc done vb
// calc durumunda b!= 0 ise reg a ve reg b güncellenir aksi halde done durumuna geçer

// a_in, b_in 16 bit
// start tetik sinyali
// clk, reset

// çıkışlar 
// gcd_Out 16 bit sonuç done
// fsmd verilog kodu 
// aşağıdaki kod 16 bit girişli basit bir gcd hesaplayıcıya aittir not % operatörü mod verilogda sentez araçları tarafından desteklenebilir ama fpga bölme mod genelde maliyetli olur küçük bit genişliklerinde makul büyük bit gneişliklerinde kaynak kullanımına dikkat edilmeli veya özel ıp kullanılmalı

module gcd_fsmd(
    input wire clk,
    input wire reset,
    input wire [15:0] a_in,
    input wire [15:0] b_in,
    input wire start,
    output reg [15:0] gcd_Out,
    output reg    done
);

// data path regısters
reg [15:0] regA, regB;

// FSM STATES
localparam IDLE = 2'b00,
            CALC = 2'b01,
            DONE = 2'b10;
reg [1:0] current_state, next_state;

// 1) state regıster
always @(posedge clk or posedge reset) begin
  if ( reset) begin
    current_state <= IDLE;
  end else begin
      current_State <= next_state;
end
end

// 2 data path regısters
always @(posedge clk or posedge reset) begin
    if (reset) begin
        regA <= 16'd0;
        regB <= 16'd0;
    end else begin
        case(current_state)
            IDLE: begin
                if(start) begin
                    regA <= a_in;
                    regB <= b_in;
                end
            end

            CALC: begin
                // eğer b !=0 ise a <- b; b<- a mod b
                if (regB != 16'd0) begin
                    regA <= regB;
                    regB <= regA % regB; // combinational mod
                end
                // b = 0 olursa bir sonraki clockta done geçeceğiz
            end

            DONE: begin
                // bu durumda regA zaten GCD
                // registerları sabit tutatbiliriz

            end
        endcase
    end
end

// 3) next state & output logıc 
always @(*) begin
    // varsayılanlar 
    next_state = current_state;
    gcc_out    = reg A;
    done       = 1'b0;

    case (current_state)
        IDLE: begin
            if (start)
                next_state = CALC;
        end

        CALC: begin 
            if (regB ==16'd0) begin
                next_state = DONE;
            end
        end
        
        DONE: begin
            done = 1'b1; // sonucu hazır
            // istersen buradan tekrar ıdle veya direk beklemeye giebilirsin
            // next_State = IDLE;
        end
    endcase

end

endmodule

// açıklamalar
// ıdle start geldiğinde reg a ve regb girişlerden yüklenir
// calc regB != 0 İSE REGA <= REGB; REGB <= REGA % REGB;
// B == 0 OLDUĞUNDA BİR SONRAKİ CLOCKTA DONE DURUMUNA GE.ER
// DONE = 1 REGA DEĞERİNDE GCD SAKLI
// algoritma her loopta bir mod işlemi yaprak gcd'yi buluyor gerçekte bir whlile döngüsü gibi ama fsmd mantığında herclok çevriminde bir adım atıyor

// tasarım notları ve optimizasyon
// büyük bit genişlikleri 
//% mod operatörü fpga de yüksek kaynak kullanımı gerektirebilir
// sentez aracı bazen otamatik bir bölme ıosi ekleyebilir xilinx divider generator
// ya da sözde ardışık iteratibve bir mod hesaplama devresi tasasrlayıp fsmd döngülerine yaptırırsınız
// zaöam paylaşımlı modül kullanımı
// başka işlemler de varsa çarpma bölme gibi bir aritmetik çekirdek anyı fsm içinde fakrlı clocklarda paylaştırılabilir.

// sıfır tesppiti 
// bazı tasarımlarda z = regb == 0 sinyali ek bir ff ile senkron tutulur gecikme yönetimi gerekirç bizim örneğimizde basit olsun diye direk kıyaslama yaptık

// reset yapısı asenkron reset kullandık gerçek projede senkron reset tercih edilebilir veya global  set reset fpga özelliğikullanabilirsiniz
// fsm data path ayrımı kod daha d abüyüdüğünde fs m ve data path bloklarını farklı modüllerde tnaımlayıp üst seviyede bağlayabilirsiniz bu okuma bkaım açıısından kolaylık sağlar 

//F) Testbench ve Doğrulama
//Test Senaryoları:
//(a_in, b_in) = (12, 8) => GCD = 4
//a_in, b_in) = (15, 0) => GCD = 15 (hemen sonlanır)
//(a_in, b_in) = (21, 7) => GCD = 7
//Dalgaları İzleme:
//regA, regB, current_state, done vb.
//Girdi sinyallerini start ile tetikle, saat ilerledikçe regB’nin 0’a indiğini gözle.

// verilogda mod işleminin kullanımı
// FSMD YAKLAŞIMIYLA KARMAŞIK DÖNGÜSEL ALGORİTMALARIN NASIL ADIM ADIM ÇALIŞTIĞI
// DATA PATH FSM ENTEGRAYSYONUN PEKİTİRDİR
