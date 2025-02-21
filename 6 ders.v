//pipeline nedir
// büyük bir kombinasyonel işlemi 32 bitr çarma veya karmaşık bir fonsiyon tek bir clockta yapmak yerine daha küçük parçalara pipelinestage bölüp her aşamada bir register kullanarak işlemeyi sürdürme tekniği
// hedef en uzun mantık gecikmesini criticalpath kısaltarak daha yüksek saat frekansı elde etmek
// ilk veri girişi birinci aşamada işlenirken bir sonraki clockta ikinci veryi yine birinci aşamaya girer dolayısıyla işlem paralel ilerler ancak latency ilk girişten sonuca kadar geçen süre aratar

//Din -> [ Stage1: small logic + FF ] -> [ Stage2: small logic + FF ] -> ... -> Dout

// herstage aşama bir egister + basit mantık bloğundan oluşur 
// pipeline örneği basit aritmetik işlemler
// tek aşamalı çarpma
// bir 16 x 15 çarpma işlemini tek saat çevriminde gerçekleştirmeye çalışırsanız lut gecikmesi yüksk olabilir saat frkansınızı 100 mhz üzerine taşımak zorlaşabilir
//iki aşamalı pipeline dos48 blokları çarpma + toplama yapabilir eğer aşamalar arası registerları etkinleştiriseniz dsp48 bloklarını pipeline modunda kullanabilirsiniz
// ilk clockta girdiler çarpılır ara sonuç saklanır
//ikinci clockta toplama veya başka bir aşama devreye girer
// böylece yüksek frekans 200 300 mhz hatta daha yukarı mümkün olur

// pipeline kodlama örneği verilog
//2 aşamalı pipeline taslağı verilmiştir 32 bit iki sayıyı çarpıp sonuç eklemek gib i basit mantıkk grelim

module pipelined_muladd (
    input wire  clock,
    input wire  reset,
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [31:0] C,
    output reg [63:0] P,
);

    // pipeline registerlar
    reg [63:0] mul_Reg; // birinci aşama osnucu çarpma
    reg [31:0] c_Reg; // c de aynı şekilde boru hattına alınmalı

    // 1) stage 1: çarpma
    always @(posedge clk or posedge reset) begin
      if (Reset) begin 
        mult_reg <= 64'd0;
        c_reg    <= 32'd0;
      end else begin
        mul_reg <= A * B;
        // bu çarpma dsp blokta ya da lutlarda olabilir
        c_reg  <= C;
      end
    end
// 2) stage 2: toplama
always @(posedge clk or posedge reset) begin
    if (Reset) begin
        p<= 64'd0;
    end else begin
        // bir önceki aşamada eld edilen çarpım mult_Reg ve
        // pipeline'a alınmış c değeri c_Reg
        P <= mult_reg + c_reg;
    end
end

endmodule

//Clock 1: A * B hesaplanır, sonucu mult_reg’e kaydeder. Aynı anda C de c_reg’e aktarılır.
//Clock 2: mult_reg + c_reg toplanarak P kaydedilir.
//Her yeni clock’ta yeni A,B,C gelebilir ve pipeline doldukça her clock çıkışta yeni sonuç elde ederiz.

// önemli not pipeline yaylı bant gini çalışır ilk sounç 2 clock sonra çıkar latency 2 fakat her clockta yeni veri besleyebilirsiniz daha yüksek throughput

// pipeline fsmd
// fsmd tek bir veri kümesi üzerinde adım adım işlem yapan bir yaklaşım bir clock çevriminde ufak bir alti şlemi tamamlar durumlar arasında geçiş yapar
/// pipeline her clockta yeni veri girişi alarak yüksek throughput sağlar birden fazla veri paralel işlenir
// kombine kullanım büyük bir modül çarpma bölme pipeline haline getirilir fsmd pipeline beslenme sırasını ve verinin nereye gideceğini yönetir.

//E) Zamanlama Analizi ve Retiming
//Zamanlama Analizi

//Vivado/Quartus gibi araçlarla “timing report” alır, kritik yol gecikmesine bakarsınız.
//Gerekirse pipeline aşamalarını artırırsınız.
//Retiming (Sentez Aracı Otomatik)

//Modern sentez araçları, register’ları otomatik şekilde kaydırarak (retiming) kritik yolu kısaltabilir.
//Kodunuzda “pipelining’e engel olmayan” bir yazım tarzı (ör. asenkron reset kullanmamak, senkron reset veya enable sinyalleriyle tasarım) retiming’in verimli çalışmasına yardımcı olur.   

// register balancing uzun bir kombinasyonel yol yerine araya ek registerlar ekleyerek yolu bölmek pipeline stage

// rosource duplicatrion sentez aracı yüksek fan out sinyalleri çoğaltarak performansı artırabilir regislter replication
// sub module pipelinnig bir fır filte tasarımında her tap aşama bir pipeline registera sahip olabilir.
//Pipeline tasarımının temel mantığını,
//Basit bir Verilog örneğiyle 2 aşamalı pipeline yaklaşımını,
//FSMD ile pipeline arasındaki farkları,
// Multi-clock design (farklı saat bölgeleri) ve senkronizasyon konularına geçiş yapabiliriz.
//Bir sinyalin bir saat domain’inden diğerine nasıl güvenli aktarılacağı, metastabilite ve FIFO kullanımını konuşabiliriz.