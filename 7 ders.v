// bir önceki sohbetimizde pipeline tasarımını ve yüksek performans tekniklerini ele aldık farklı saat bölgeleri multi clock design arasınd averi paylaşımının nasıl yağolacağını metastabilite tehlikesini ve senkronizasyon yöntemlerini inceleyelim.

//multi clock tasarım nedir
// bir fpga veya asıc içerisinde birden fazla saat clock sinyali kullanmak
// clkA = 100mhz clkB = 200 MHz
// veya farklı faz farklı kaynaktan gelen saat sinyalleri harici bir veri akışı 125 mhz dahili sistem 50 mhz

// harici protokoller farklı hızlarda çalışır ethernet pcl
// büyük dijitial sistemlerde farklı fonksiyon blokları farklı saatlerde en verimli şekilde çalışabilir

// senkronizasyon bir saat domaininde üretilen sinyal başka bir saat domainde kullanıldığında metastabilite riski ortaya çıkar

// metastabilite ve senkronizasyon mekanizması
//metastabilite
// bir flip flopa setup hold zamanını ihlal edecek şekilde veri gelir veya saat domaini uyuşmazlığı varsa metastable duruma geçebilir
// metastabil durum flip flop çıkışının belirsiz bir süre kararsız kalmasına yol açar
/// tamamen engellenemez ancak MTBF Mean time Between Failures dğeeri yükseltilebilir yani metastabvil olayların sıklığı azaltılabilir.

//bir domainden gelen asenkron sinyal veya başka domainin sinyal i yeni domainde art arda iki flip floptan geçirilir.
// ilki metastabil olabilir ikincisi metastabiletenin yeni domaine yayılma olasılığını çok düşürür

 ----->| FF1 |----->| FF2 |-----> Senkron Veri
        ^        ^
       clkB     clkB
// ff1 metastabil olabilir ancak ff2 çıkışımım metastabil devam etme olasılığı çok düşüktür

// flag sinyali aktarımı 
// edge detection yöntemi
// eğer farklı saat domaininde sadece kısa bir tetik pulse sinyali üretmek istiyorsanız edge detection kullanabilirsiniz
// orjinal domaininde bir toggle ya da flag sinyali atarız toogle_Reg <=  ~toggle_reg
// KARŞI DOMAİNNİDE İKİ FLİP FLOPLU SENKRONİZERLE toggle değerini okur eski toggle değeriyle kıyaslayarak kenar edge yakalarız.

// level alternation seviye değişimi 
// diğer bir teknik bir bit her event olduğunda 0 -> 1 veya 1 -> 0 şeklinde değişir. hedef domain bu bitin değişitğin yakalar

// FIFO ile clock domain crossing
// asenkron FIFO
// farklı satlerde çalışan yazma wr_clk ve okuma rd_clk kısımlarına sahip bir FIFO tasarımı
// yazma ve okuma adresleri gray kodu ile yönetilir böylece metastabilite riski azaltılır
// fıfo dolu boş sinylalerinin üretimi de senkronizasyon içerir
// nerede kullanılır
// yüksek veri hızlarında büyük hacimli veri aktarımında
// video akışı 148.5 mhzde gelir dahili işlem 100 mhzde çalışılır veriler asenkron fıfo üzerinden alınır/ verilir.

module async_fifo #(
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4
)(
    input wire                  wr_clk
    input wire                  rd_clk
    input wire                  wr_en
    input wire                  rd_en
    input wire [DATA_WIDTH-1:0] din,
    output wire [DATA_WIDTH-1:0] dout,
    output wire                  full,
    output wire                  empty
);

    // FIFO bellek
    reg [DATA_WIDTH-1:0] mem[0:(1<<ADDR_WIDTH)-1];

    // yazma işaretçesi okuma işaretçesi (Wr_ptr, rd_ptr)
    // gray kod dönüşümleri vb.
    // .....
    // bu kısımda senkronizasyon ve gray code logic detayları yer alır

    //...
endmodule

// yazma tarafı wr_Clk domaininde okuma tarafı rd_clk domaininde çalışır
// fıfo dolu boş bilgisi pointerların senkronizasyonuna dayanır

// basit two ff senkronizer ile bir sinyali aktarmak
// domain adan gelen signal a sinyalini domain bye aktarıp orada puls eşeklinde yakalamayı gösterir

module sync_pulse (
    input wire clkA,
    input wire clkB,
    input wire resetA,
    input wire resetB,
    input wire triggerA, // domain a'de bir tetik
    output wire pulseB  // domain bde tek clock süresi kadar darbe 
);

    // domain a bir toggle bit
    reg toggleA;
    always @(posedge clkA or posedge resetA) begin
      if (resetA)
         toggleA <= 1'b0;
      else if (triggerA)
          toggleA <= ~toggleA;
    end

    //domain b senkronizer
    reg [1:0] sync_regB;
    always @(posedge clkB or posedge resetB) begin
        if (resetB) begin
            sync_regB <= 2'b00;
        end else begin
            // toggleA sinyalini clkB domaininne çekiyoruz
            sync_regB[0] <= toggleA;
            sync_regB[1] <= sync_regB[0];
        end
    end

    // edge detection in domain B
    assign pulseB = (sync_RegB[0] ^ sync_RegB[1]); // toggle bit değiştiyse pulse oluşur
endmodule

// toggle A her trigger a olduğunda flip eder
// clkB domaininde iki flip flop senkronizer sync_RegB var
// pulseB senkron domainde 1 clock geniliğinde çıkar toggle değişimini gösteriyor

// çoklu saat tasarımında dikkat edilmesi gerekenler
// saat kaynağı ve PLL/MMCM
// fpga de farklı saatleri genelde dahili pll veya harici osilatörle elde ederiz
// her clock domainnin sinyalleri sadece kendi clockuna senkron olmalı 

// glitch ve asenkron hatlar
// sinyaller clock domaini arasında rastgele zamanlarda değişebilir metastabileteyi tetikleyebilir
// mutlaka senkronizerveya fıfo gibi yapıları kullanmak gerek 
// zamanlama kısıtları timing constraints
// fakrlı clock domainler arası yollar genelde false path olarak işaretlenir çünkü senkronlama mantığı var
// sentez aracında multi cycle path veya false path ayarlarını doğru yapmak önemli

// sonraki adımlar

// farklı saat domainlerindeki sinyallerin metastabilite riskini
// iki flip flop senkronizer veasenkron fıfo yaklaşımlarını
// basğit sinyal aktarımı pulse toggle yöntemlerini
// daha büyük ölçekli tasarımlarda hierarchy katmanlı tasarım
// parametrik kodlama verilog parameter veeya generate ypaıları konularına geçeibliriz
// ayrıca senkronizasyton testbench senaryolarına da kısa değinebiliriz.

