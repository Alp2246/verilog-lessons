// şimdi FSM'İN sadece kontrol tarafını control path değil bir data path veri yolu ile birlikte nasıl çalıştığını inceleyelim.
/// bu bütünleşik yapıya genelde fsmd finite state machine with datapath adı verilir.

// fsmd nedir fsm contorl path ve data path toplayıcılar çarpıcılar kayıtlar vb elemanları barındıran kısım birleşiminden oluşan bir yapıdır.
// amaç karmaşık veya çok adımlı bir işlemi sayısal filtre şifreleme modülü prtokol işlemcisi parçalara bölmek ve her adımı kontrol etmek için fsm kullanılır.
// data path ise o adımda yapılması gereken işlemi toplama çarma vs gerçekleştirir.

+-------------------+
Kontrol ---> | Next State Logic | 
(Girişler)     |  (FSM)           | ---> outX
            +-------------------+
                 |    ^
                 v    |
            +-------------------+
  Data_in -->| Data Path (Register & ALU vb.) |--> Data_out
            +-------------------+

// control path fsm hangi adımda state olduğumuzu data pathin gangi işlemi yapacğaını belirler
// data path registerlar alu çarma modülü operasyonları yapar.

// register transfer metodolojisi
// adım adım işlemler veri kayıtlardan register diğer kayıtlara belirli bir saat çevriminde transfer edilir bu sırada aritmetik veya mantık işlemleri ypaıır.
// zaman paylaşımı time multiplexing örneğin tek bir çarma modülünü farklı aşamalarda kullanarak kaynak tasarrufu sağlanır.
// ASMD Algorithmic state mach,ne + data diyagramı
// fsm diyagramına benzer fakat datapath işlemlerinin her adımda ne olacağını da gösterir.
// her state kutusunun içinde bu clock çevriminde hangi register transferi gerçekleşiyor gibi bilgiler yazar

// fsmd örneği  basit toplama döngüsü accumulator 
// senaryomuz giriş olarak gelen n adet değeri toplayıp sonuç registerına kaydetmek istediğimizi varsayalım fsm her clock çevriminde bir değeri toplayıp sayaç değeri sıfır olunca bitiş durumuna geçecek olsun.

// verilog kod yapııs 
// data path:
// acc_Reg (toplamı saklayan register)
//cnt_Reg (kalan eleman sayıcını tutan register)
// din her clockta gelen veri
//add_acc işlemi acc_Reg <= acc_reg + din
//fsm control path
// durumlar IDLE ACCUM DONE
//aCCUM durumunda her clock kenarında bir keleme yapar sayaç sıfıra inince done durumuna geçeer

module accumulator_fsmd(
    input wire  clk,
    input wire  reset,
    input wire [7:0] din, // gelen veri
    input wire [7:0] num_samples, // toplanacak değer adedi
    input wire    start,
    output reg [15:0] sum_out, // sonuç
    output reg    done

);

    // data path için registerlar
    reg [15:0] acc_reg;
    reg [7:0]  cnt_reg;

    // FSM durumları
    localparam IDLE = 2'b00,
               ACCUM = 2'b01,
               DONE  = 2'b10;
    reg [1:0] current_state, next_state;

    // ================1) state register ===========
    always @(posedge clk or posedge reset) begin 
        if (reset) begin
            current_state <= IDLE;
            end else begin
                current_state <= next_state;
            end
        end

        // ==============2) data path register =========
        always @(posedge clk or posedge reset) begin
          if (reset) begin
            acc_reg <= 16'd0
            cnt_reg <= 8'd0;
          end else begin
            case (current_state)
              IDLE: begin
                if (start) begin
                  // başlangıç
                  acc_reg <= 16'd0;
                  cnt_reg <= num_samples;
                end
              end

              ACCUM: begin
                // TOPLAMA İŞLEMİ
                acc_reg <= acc_reg + din;
                // SAYAÇ DÜŞÜR
                cnt_reg <= cnt_reg -1;
              end

              Done: begin
                // normalde done durumunda registerlar sabit kalabilir
                // acc_Regi değiştirmiyiyoruz
              end
            endcase
          end
        end

        // ============3) next state output logic kombinasyonel========
        always @(*) begin
          // varsayılan değerler
          next_state = current_state;
          sum_out    = acc_reg;
          done       = 1'b0;

          case (current_state)
              IDLE: begin
                if (start)
                next_state = ACCUM;
              end

              ACCUM: begin
                if (cnt_Reg == 8'd1) begin
                  // bu clockta son değer toplanacak
                  // sonraki clockta done durumuna geçeceğiz
                  next_stae = DONE;
                end
              end
            DONE: begin
              done = 1'b1; // bitmiş sinylai
              // yeni iş istersen yine ıdle dönebilirsin
              // next_state = ıdle;
            end
          endcase
        end
endmodule

// state register current_State senkron olarka güncelleniyor
// data path register acc_Reg ve cnt_Reg iyne senkron her durumun gerektirdiği işlem case current_State içinde ypaılıyor
// kombinasyonel mantık
// next_State ile hangi duruma geçileceğini
// sum_out ve done gibi çıkışları belirliyor
// bu modele iki değil 3 process benzeri bir yapı var
//state register 
// data path register
// kombinasyonel next state & output
// bu da bir fsmd dir çünkü fsm + data path register ve aritmertik işlemleri kontrol ediyoruz

// kodlama stratejileri
// data path register ile fsm registeri aynı always bloğunda birleştirme
// isterseniz fsm duru mregisterı ve data path rwegıstarları tek always @(posedge clk..) içinde yde yazabilirsiniz
// bu her clokc kenarında hem durum hem de data path güncelleniyor dmeektir genelde soru n yoktur ama kod okunabilirliği açısından bazen ayrı tutmak daha iyi olabilir

// zaman paylaşımlı kaynaklar
// eğer toplama ve çarpma işlemi varsa her adımda aynı dsp bloğunu farklı amaçla kullanabilirsiniz fsm hangi çevrimde ne yapacağını enable sinyalleriyle denetler

// pipeline tasarımı 
// büyük işlemleri birkaç pipeline aşamısına böüp fsmd her aşamada veriyi ileri taşımasını sağlayabilirsiniz
// asmd şeması
// ıdle durumunda registerları sfırla
// ACCUM DURUMUNDA Her clockta acc_Reg <= acc_Reg + din
// done durumunda done=1
// yukarıdkai accumulator örneği basit daha karmaşık işlem 32 bit çarpma eklediğinzde dsp bloklarından yaralanmak isteyebilirsiniz
// acc_Reg 16 bit cnt_Reg 8 bit sentez aracı lut + ff veya bloc ram gibi kaynaklara yerleştirilebilir 
// asenkron sinyaller
// start gibi dış siynaller genelde snekronizasyon işleminden geçmelidir basit olsu n diye direk kullandık ama gerçek tasarımlarda 2 flip flop senkronizer önemli
// çok aşamalı rişlemler mesela acc?Reg ek olarak çarpma bölme dziziye eirşim gibi işlemleriniz varsa FSMD yapısında birkaç durum ekleyip data path üzerinde hang i clockta hangi modül aktif olucak sorusunu çözeceksiniz

// bir Bir sonraki sohbetimizde, daha karmaşık örnekler (örneğin çarpma tabanlı FSMD, bellek kullanan FSMD vb.) ve kod optimizasyon konularını işleyeceğiz.
//Ayrıca “pipeline vs. FSMD” konusunu da kıyaslayarak hangi senaryoda hangisinin tercih edildiğine değineceğiz.