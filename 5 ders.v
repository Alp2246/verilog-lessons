// bellek block ram register file kullanımı ve resorurce sharing kaynak paylaştırma kavramlarına odaklanacağız

// bellek ile etkileşimli fsmd
// block ram bram veya register file
//fpgade dahil i belleklerle block ram etkileşime girecek bir fsmd tasarladığnızda bellek arayüz sinyallerinin addres data in data out we en kontrolü fsm tarafından yapılır. adata path tarafında bellekten gelen veriyi işler kayıtlard asaklar vb.

// örnek esnaryo 256 adet 16 bitlik veri bramde saklı fsmd bu verileer üzerinde teker teker işlem yapacak 

// fsm ıdle read process wrıte next addr gibi durumlar aracılığıyla adresi arttırıp belleğe okuma yazma komutları verir
// data path okunan veriyi alır aritmetik işlem yapar ve sonucu tekrar bellleğe yazabilir.

module bram_fsmd (
    input wire      clk,
    input wire      reset,
    input wire      start,
    // bellek arayüzü senkron bram varsayalım 
    output reg [7:0] addr,
    output reg       we,
    output reg [15:0] data_out,
    input  wire [15:0] data_in,
    output reg    done
);

    //durumlar
    localparam IDLE = 2'b00,
               READ = 2'b01,
               proc = 2'b10,
               FINISH = 2'b11;
    reg [1:0] current_state, next_state;
    reg [7:0] counter; // 256 elamanı gezmek için

    // 1 ) state register
    always @(posedge clk or posedge reset) begin
      if (reset)
          current_state <= IDLE;
      else
          current_state <= next_state;
    end

    // 2) data path register & bellek kontrol
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            addr  <= 8'd0;
            we    <=1'b0;
            data_out <= 16'd0;
            counter <= 8'd0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (start) begin
                        addr  <= 8'd0;
                        counter <= 8'd0;
                    end
                end

                READ: begin
                    // bellekten data_in geelecek
                    // address = addr
                    we  <= 1'b0; // okuma
                    // sonraki çevrimde data_in kullanılabilir
                end
            
                proc: begin
                    // data_in elde
                    // örnek bir işlem: data_out <= data_in +1
                    data_out <= data_in +1;
                    // yazma hazırlığı
                    we   <=1'b1;
                end

                FINISH: begin 
                // örnek bir sonraki adresi ayarla 
                addr   <= addr +1;
                counter <= counter +1;
                end
            endcase
        end
    end

    // 3) next state & output logic
    always @(*) begin
        next_State = current_state;
        done      = 1'b0;

        case (current_state)
          IDLE: begin
            if(start)
            next_state = READ;
          end
        READ: begin
            // bellek okuması senkron olduğundan
            // data_in geçerli olacak => bir sonraki clockta proc
            next_state = PROC;
        end

        PROC: begin
            // işlem yaptık, data_out hazır, yazmaya gidiyoruz
            next_State = FINISH;
        end

        FINISH: begin
            // 256 elamanı gezelim
            if (counter == 8'd255)
                done = 1'b1 //bitti
            else
                next_state = READ;

        end
      endcase
    end
endmodule

// read durumunda bellekten veri okunur we=0 senkron bram olduğu için bir sonraki clock çevriminde data_in elde edilir
//proc durumund agleen veriyii şlleyip data_out atıyoruz we=1 yaparak yazmaya hazırlanıyoruz
// fınısh durumund aadresi arttırıyoruz ve döngüyü sürdüyürüyoruz
// böylece fsmd bram adresini yönetiyor ve okuma yazma aşamalarını saatrli bir şekilde koordine ediyor.

// resource sharing kaynak paylaştırma
// tanım birden fazla hesaplama veya işlem bloğu yerine tek bir donanım kaynağonı çarma birimi toplama birimi farklı saat döngülerinde kullanmak
// alan tasarrufu özellikle büyük bit genişilkş bçarma bölme modülleri lut ütketimi veya dsp bloklarını hızlıca doldurabilir. tek bir dsp modülünü paylaştırarark maaliyet düşürülebilirç
//Dezavantaj: İşlem süresi artabilir, çünkü sıra ile kullanılır.

// durum1 mult_ in1 @= xİ mult_in 2 y=; dsp modülü ile çarp
//Durum2: mult_out1 <= mult_result; // DSP sonucu kaydeder
//Durum3: mult_in1 <= A; mult_in2 <= B;
//Durum4: mult_out2 <= mult_result;
// aynı dsp bloğu sırayla kullanılır fsm hangi çevrimde hangi çarpmanın ypaılacağını kontrol eder.
//2) Kodlama Yaklaşımı
//Data Path tarafında “multiplier” giriş/çıkış register’ları.
//Tek bir “always @(*)” veya IP core ile çarpma sonucu “mult_result” elde edilir.
//FSM, hangi çevrimde hangi veri çarpılacak, sonucu hangi register’a yazılacak, hangi enable sinyali aktif olacak gibi kontrol sinyallerini üretir.
 +-----------------+     X, Y    +-----------+
 |   FSM (Control) | ----------->|           |
 |  next_state     |     A, B    | Mult/ALU  |--> mult_result
 +-----------------+             +-----------+
        |    ^
        |    | kontrol sinyalleri (select, we, vb.)
        v    |
 +-----------------+
 | Data Registers  |
 +-----------------+
//3) Kaynak Paylaştırmaya Dikkat Edilecek Hususlar
//Zamanlamanın Artması: Her işlemi farklı clock çevrimlerinde yapacağınız için throughput (birim zamanda işlenen veri miktarı) düşebilir, fakat donanım kaynak kullanımınız azalır.
//Sentez Aracının Otomatik Paylaştırması: Bazı sentez araçları, “resource sharing” optimizasyonunu kendiliğinden yapabilir. Kodda if/else veya case yapısında benzer işlemler varsa birleştirebilir.
//İstediğiniz Gibi Paylaştırma: Bazen tasarımcı, paylaştırma yerine paralel işlem için iki DSP kullanmayı seçebilir (ör. yüksek performans gerekirse).

//pipeline aynı hesaplama birimini ardışık katmanlar abölüp yüksek hız yüksek frekans elde etmek için kullanılır. her clockta yeni veri girebilir ancak tam sonuç birkaç 
// fsmd adım adım ilerleyen bir kontrol yapısıdır her clock çevriminde bir alt adım gerçekleştirilir okuma yazma hesaplama
// karma model büyük veri işleme blokları pipeline yapılır fsm veri beslemeyi okumayı yönetir özellijle dijtia sinyal işleme dsp tasarımlarında yaygın 
