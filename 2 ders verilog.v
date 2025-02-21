//KOD YAPISI ALWAYS @(POSEDGE CLK OR POSEDGE RESET)
// saat kenarında emvcut durumu günceller
//always @(*)
// kommbinasyonel olarak gelek durumu next state ve çıkışı hesaplar

module moore_fsm (
    input wire clk
    input wire reset,
    input wire inA,
    output reg outY
);

    // DURUM KODLAMA İÇİN BİR ENUM BENZERİ
    // systemverilog destekliyorsa enum kullanılabilir ama
    // klasik verilogda localparam veya parameter kkullaıyoruz

localparam s0 = 2'b00,
           s1 = 2'b01,
           s2 = 2'b10;

reg [1:0] current_state, next_state;

// 1) state register senkron
always @(posedge clk or posedge reset) begin
  if (reset) begin
    current_state <= s0;
  end else begin
    current_state <= next_state;
 end
end

// 2) next state & output logic kombinasyonel
always @(*) begin
    // varsayılan atamalar
    next_state = current_state;
    outY       = 1'b0;

    case (current_state)
        s0: begin
            outY = 1'b0;   // MOORE ÇIKIŞ SADECE DURUMA BAĞLI
            if (inA)
                next_state = S1;
        end

        S1: begin
            outY = 1'b1;
            if (!inA)
                next_State = S2;
        end

        s2: begin
            outY = 1'b0;
            if (inA)
                next_state = S0;
        end

        default: begin
            next_state = S0;
        end
    endcase
end

endmodule

// açıklamalar s0 s1 s2 durumlarını localparam olarka tnaımladık
// always@(posedge clk or posedge reset) bloğunda senkron güncellemeyi yaptık
// always @(*) bloğunda hem helecek durum (next_STate) hem de Moore çıkışı outY hesaplanıyor
// Moore FSM OLDUĞUNDAN OUTy TAMAMEN MEVCUT DURUMU N BİR FONSKİYONU GİRDİ NİA SADECE GELECEK DURUMU BELİRLEMEDE KULLANILIYOR

// mealy fsm iki always bloğu ile kodlama
// mealy fsmde çıkış sadece mevcut durumdan değil girdi sinyalinden de doğrudan etkileneebilir.
// iki durumlu basit bir mealy fsm gösterir s0 s1 burada outz ina girdisinin anlık değerine tepki verebilir

module mealy_fsm(
    input wire clk,
    input wire reset,
    input wire inA,
    output reg outZ
);

    // durum tanımlamaları
    localparam s0 = 1'b0,
                s1 = 1'b1;

    reg current_state, next_state;

    // 1) STATE REGİSTER
    always @(posedge clk or posedge reset) begin
        if ( reset) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end

    //2) Next state & output Logic
    always @(*) begin
        next_state = current_state;
        outZ       = 1'b0;

        case (current_state)
            S0: begin
                // Mealy: eğer inA = 1 olduysa direkt outZ=1 olabilir
                if (inA) begin
                    outZ    = 1'b1;
                    next_state = s1;
                end
            end

            s1: begin
                // Durum s1'de ina== olursa geri s0'a dönüyoruz
                if (!inA) begin
                    next_state = S0;
                end else begin
                    outZ = 1'b1;
                end
            end
            default: begin
                next_state = S0;
            end
        endcase
    end
endmodule

// burada outz hem durum hem de ina 'ya bağlı mealy mantığı
// ina anlık olarak değştiğinde henuz clock vurmadan bile outz güncellenebilir.
// daha yüksek hızlarda veya karmaşık zamanlama gereksinimlerinde giriş sinyallerini senkronize etme ve ek önlemler almak gerekir.

// FSM tasarımında verilog önerileri

// senkron resetmi asenkron reset mi
// bazı projelerde always @(posedge clk) + if (reset) şeklinde senkron reset tercih edilir.
//fpga'de genelde senkron reset daha stabil ve öngörülebilir zamanlama sunar. ancak kod örneklerinde eğitim amaçlı asenkron reset de gösteirlir.

// durum kodlaması yukarıdaki örneklerde localparam kullanıp binary kodlama yaptık sentez aracı one hot veya gray gibi tekniklerle de kodlyabilirç

// komplesk fsmlerde one hot kodlama ile hız artışı veya alan optimizasyonu sağlanabilir.
// giriş sinyallerrinin senkronizasyonu
// dış kaynaktan gelen asenkron sinyaller seri veri hattı önce 2 flip floplık senkronizerden geçirilip sonra fsme verilmelidir. aksi halde metastabilitite riski doğabilir.

// zamanlama analizi
// fsm'de kritik yol genelde kombinasyonel mantık + durum register arasındaki gecikmedir.
// tasarım büyüdükçe pipeline eklemek veya mantık yolunu kısaltmak için fsm ypaısı gözden geçirilir.

// dığrulama testbench ipıçları
// fsm geçişlerini test etme
// tüm durumlar states ve geçiş yollarının dnenemesi gerekir
// her durumdayken girdilerin fakrlı kombinasyınlarını test edin

// reset seneryosu
// tasarımın reset altındaki davranışı varsayılan durm gözlenmeli
// zamanlama diyagramı
// simülasyon dalga penceresinde waveform current_State, next_state, ina, outy/outz gibi sinyalleri izleyin.

// özet ve bir sonraki adım
// moore mealy fsm örneklerini
// iki always yaklaşımı ile durum saklama ve geçiş mantığını
// kodlama önerilerini

