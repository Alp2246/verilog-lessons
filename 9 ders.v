// hierarchical tasarım ve parametrik modüller konusunu inceledik.bu sohbetle testbench test tezgahı kavramına ve kod doğrulama tekniklerine odaklanacağız
// testbencj tb nedir neden önemlidir
// testbench tasarladığınız rtl modülünü device under test belirli girişlerle besleyen çıkışlarını gözlemleyen ve gerektiğinde doğrulayan assert/Check bir simülasyon çerçevesidir.

// amaç: tasarımın doğru çalışıp çalışmadığnı kontrol etmek
// farklı senaryoları deneyerek köşe durumları corner cases test etmek
// zamanlama senkronizasyon ve fsm geçişlerini dalga vaveform pencerisnde incelemek

// donanımsal anlamda gerçekte fpga üzerinde harici test için benzer mantık kurmak zordur yazılımsal simülasyonda testbench devreye dair tüm dalgaları gözlemleme imkanı verir.

// testbench temel yapısı
// verilog testbench genellikle şu parçalardan oluşur
//clock jenaratörü testbenchte clk sinyalini belirli bir periyotla toggle eden bir blok
// reset yönetimi başlangıçta bir reset darbesi uygulamak ardından sıfırlamak
// dut ınstantiate asıl tasarım modülünün oluşturulması portların testbench sinyallerine bağlanması
// stimulus uyarıcı üretme dur girişlerine start data_in çeşitli değerler verme senaryoları deneme
// monitör chech çıkışları izleme gerektiğinde if $display...() veya assert tarzı kontroller ypama

`timescale  1ns/1ps

module tb_example;
    // 1) tb iç sinyaller
    reg clk;
    reg reset;
    reg [7:0] din;
    reg start;
    wire done;
    wire [15:0] dout;

    //2) dut instantiate
    example_design dut (
        .clk (clk),
        .reset (reset),
        .start (start),
        .din (din),
        .done (done),
        .dout  (dout)
    );

    // clock oluşturma
    initial begin
      clk = 0;
      forever #5 clk =  ~clk; // 10ns period => 100 MHz
    end

// 4) test senaryosu
initial begin
    // başlangıç değerleri
    reset = 1;
    start = 0;
    din = 8'd0;

    // bir süre reset aktif
    #20;
    reset = 0;

    // birinci deneme
    #10;
    din = 8'd15;
    start = 1;
    #10;
    start = 0;

    // bekle done işaretini gizle
    wait(done);

    // ikinci deneme vb.
    // ....

    // simülasyonu bitir
    #100;
    $finish;
end

// 5) izleme opsiyonel
initial begin 
    $monitör("time=%t, clk=%b, reset=%b, start=%b, din=%d, dout=%d, done=%b"),
             $time, clk, reset, start, din, dout, done);
  end

endmodule

// initial begin ... end blokları testbenchte kullanılabilir çünkü bunlar sadece simülasyon aşamasında çalışacak yazılımsal süreçlerdir
// #10; komutu 10 simülasyton zaman birimi bekletir
// wait done ifadesi done sinyali 1 olana kadaar bekler
// $monitor $display $ finish gibi fonksiyonlar testbenche özel sistem fonksiyonlarıdır sentezlenmezler yalnızca simülasyon içindir.

// veri dosyası file ı/O
// testbench bir dosyadan giriş vektörlerini okuyabilir $fopen $fscanf
// çıkışları başka bir dosyaya yazar böylece otamtik kıyaslama golden output yapılabilir.

/// otamtik kontrol ve assert
// if (expected_value != dout) $error("mismatch!"); vb mantık
// bu sayede pass/fail raporu üretileilir

// bus functional model bfm
// karmaşık protokoller spı ıart axı için testbench tarafında protkol danranışını modellleyen kod
// dut ile gerçekçi iletişim kurar

// systemverilog testbench
// systemveirlog sınıf temelli calss based testbenvh yazma random tes t gerneration coverage ileri yetenekle r sunar
// kalsik verilogda basit prosödür kullanılarbilir

// coverage ve doğrulama stratejileri
// functional coverage
// tüm olası durumların test senaryolarıınn denendiğinden emin olmak
// systemverilogda covergroup gibi yapılar kullanılabilir klasik verilogda manuel takiple yapılıur

// code coverage
// ticari simülatörler modelsim vcs hangi satırlar hangi dallar if else testte ytürütüldü bilgisi verir.

// corner cases
// özellikjle fsm geçişlerinde reset -Z start start-> idle gibi sıra dışı geçişleri test etmek
// asenkron giriş testleri mesela buton harici veri vs

// regrersyon testi
// tüm testleri bir komutla scripty çalıştırıp otamtik rapor almak
// büyük projelerde ger kod değişikliği sonrası regresyo n çalışır var olan işler bozulmadı mı diye kontrol edilir.

// gerçekte fpga üzerinde tüm sinyallerin dalga formunu izleyemezsiniz pin kısıtı lojik analiz eklemeniz gerekir vs nbu nedenle simülasyon testbench aşaması çok kritiktir. labaratuvar ortamında test etmeden önce 
// mümkün mertebe simülasyon ile hataları yakalamak en iyi praitk yöntemdir.

// ipuöları
// kısa modüler testler
// her alt modül için ayrı testbench sonra top modül için entegre testbench
// gerçekçi beklemeler
// baız sinyallerin gedcikmeli olduğun u simüle etmek veriyi 2 3 clock sonra beslemek
// monitör vs otamtik kıyas
// manuel gözlem yetebilir ama otamtik pass fail assert if chechk yaklaşımı hataları hızlı yakalar

// sonrak adımlar
// testbench temel yapısını
// gelişmiş ve assert yöntemleribi
// coverage ve doğrulama stratejilerini
// tasrım aşışının sentez sonrası aşamalarına place route timing closure ve fpga özel kısıt dosyalarının xdc nasul kullanıldığına göz atıp timing analysis sta static timing amnalysis konularını ele alacağız.


//A) Derleme (Compile) Süreci ve Sentezden Sonraki Adımlar
//Sentez (Synthesis)

//HDL kodu alır, “RTL → netlist” dönüşümünü yapar.
//FPGA spesifik kaynaklar (LUT, FF, DSP, Block RAM) üstüne bir optimizasyon görürsünüz.
//Place & Route (Yerleştirme & Yönlendirme)

//Sentez sonucu elde edilen netlist, FPGA’deki fiziksel kaynaklara (CLB/LAB vb.) yerleştirilir.
//Ardından bu hücrelerin arasındaki bağlantılar (routing switch matrix) belirlenir.
//Amaç: Zamanlama kısıtlarına (clock period, I/O kısıtları vb.) uyacak şekilde optimal yerleştirme ve yönlendirme sağlamak.
//Bitstream Oluşturma

//P&R tamamlanınca, FPGA’ye yüklenecek konfigürasyon dosyası (bitstream) üretilir.
//Static Timing Analysis (STA)

//Yerleştirme-yönlendirme sonrası gerçek kablo gecikmeleri hesaplanır, clock period ve setup/hold zamanları kontrol edilir.
//Kullanılan araç (Vivado, Quartus vb.) “timing report” vererek hangi yollarda (paths) gecikmenin kritik olduğunu gösterir.

// timing constraints
// tasarımımızın çalışacağı hedef frekans giriş çıkış gecikmeleri çoklu saat domain ayarları konularda araca rehberlik etmek

//Xilinx XDC (Xilinx Design Constraints) veya Altera/Intel SDC (Synopsys Design Constraints)

//create_Clock -name clk -period 10.0 [get_ports clk] gibi komutlar ile clk periodunu(100 MHz) tanımlarsınız
// griş ve çıkış sinyallerinin setup/hold ihtiyaçlarını da set_input_delay, set_output_Delay komutlarla belirtirsiniz

// create_Clock clock peeriyodu belirler.
// sen_input_Delay set_output_Delay harici verinin fpga ne kadar zamanda stabilize olması gerektiği fpgaden çıkışın ne kadar zamanda hazır olacağı
// set_multicycle_path bazı yollarda birden fazlaclockı kapsayan yol
// set_False_path bazı mantık veya senkronizasyon yolları timing analizi dışında tutulur asenkron FIFO pointer senkronizasyonu

create_clock -name sysclk -period 10.0[get_ports {clk}]

//#giriş sinyali 3 ns kaynakta gecikmeli geliyor diyelim
set_input_delay -clock sysclk 3.0 [get_ports {data_in}]

//#çıkış sinyali için 2 ns board gecikmesi bekleniyor
set_output_Delay -clock sysclk 2.0 [get_ports {data_out}]

//C) Place & Route (P&R) Özeti
//Placement (Yerleştirme)

//LUT, FF, DSP, Block RAM gibi kaynakların FPGA matrisi içinde hangi “slice” veya “block”ta konumlanacağı belirlenir.

// yüksek fan-out sinyaller clock enable bazen replicate çoğaltma edilir

//Routing (Yönlendirme)

//Yerleştirme sonrası, bu kaynaklar arasındaki bağlantıları hangi yönlendirme kanallarından (switch matrix) geçeceği saptanır.
//Zamanlama kısıtlarını karşılamak için kritik yollar mümkün olduğunca kısa kablo segmentleriyle bağlanır.

//Tool’un Otonom Kararları

//Genelde tamamen otomatik.
//Çok kritik tasarımlarda veya özel durumlarda “floorplanning” yapmak (manuel kısıtlarla bazı modülleri spesifik bölgelere sabitlemek) gerekebilir.
// timing closure zamanlama uyumluluğu
// amaç hedeflenen saat frekansında tüm yolların setup/hold gereksinimlerini sağlamak

// kritik yol gecikmesi < clock periyodu - ( setup + clock skew)
// bazı durumlarda pipeline eklemek veya kaynak paylaşımı azaltmak gibi rtl iyileştirmeleri gerekir.

// iteratif süreç 
// eğer araca clock period = 5ns (200MHz) dediniz ancak p&r sonunda rapor 2ns fazlalık var fail diyorsa RTL'İ GÖZDEN GEÇİRİP PİPELİNE KELEMELİSİNİZ VEYA CONSTRAİNTİ YUMŞATMALISINIZ ( DAHA DÜŞÜK FREKANS)
/// zamanlama hedefi eğer 200 mhz tutmuyorsa 180 mhz inebilirsiniz a da kod optimizasyonuna gidersiniz

// dynamic simülasyona bağımlı değil tüm olası input kombinasyonlarını düşünükür tasarımın en kötü gecikme yolu analiz edilir
// setup hold recovery removal
// sta araçları bu parametreleri inceler setup hold ihlalleri varsa raporda negativ e slack görülür.
// slack
// posotive slack yeterli zama nvar iyi 
// negative slack tasaırm geçemiyor hız aşırı yüksek veya mantık yolu çok uzun 

//Slack Report:
//Path #1:  -0.65 ns (FAIL)
//Path #2:  +0.33 ns (PASS)
//...

// sık karşılaşılan sorunlar ve çözüm yolları
// fazla uzun kombinasyonel yol
// çözüm pipelining daha fazla register aşaması eklemek
// fazla fan out tek sinyal çok yeri sürüyor
// çözüm sentez aracının replicate registers özelliğini veya manuel duplicate stratejisni kullanmak
// asenkron yol veya yanlış constraint
// multi clock crossing sinyallerinin false path olarak işaretlenmesi veya fıfo ile senkronizasyon
// dış dünya ile inrerfacelerde input/ output  delay değerlerini doğru belirlemek çok önemli

// sentez sonrası fpga yerleştirme yönlendirme aşaması
// timing constraints xdc sdc ayarları
// timing closure için gerekli teknikler pipeline resoruce duplication
// sta raporlarının nasıl yorumlandığı

// fpga tasarım sürecinde fiziksel tasarım floorplaninng pin  assignment test lojik analiz yaklaşımlarına değinebiliriz son kısımlarda yer alan design review ipuçları sıralı tasarım best practices özeyletebiliriz.

