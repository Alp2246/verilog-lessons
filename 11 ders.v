// fiziksel tasarım floorplanning pin assignment ve dahili lojik analiz
//(ILA/chipSCOPE/SİGNALTAP)

// sentez sonrası aşamalar timing constraints ve sta static timing analysis konusuna değindik. fiziksel tasarım boyutunu floorplanning pin assignment ve fpga dahili lojikk analiz yöntemlerini Ila chipscope signaltap KONUŞALIM

// FLOORPLANNİNG NEDİR
// fpga içerinse belirle modülleri belirli bölgelere region kısıtlamaktır.böylece yerleştirme palcement aracı o modülü sadece o bölgenin içine yerleştirir
// yüksek hız veya düşük gecikme gereken kritik bileşenlerin birbirleriyle yakın yerleştirilmesi için kullanılabilir

// neden gereklo olabilir
// zamanlama kritik yolları kısa tutmak için modülleri yakına sabitlemek
// mantıksal ayrışma farklı clock domainleri veya devredeki büyük IP bloklarını fiziksel olarak ayırmak
// reconfiguraation bazı gelişmiş tasarımlarda partial reconfiguration alanlarını sabitlemek

// xilinx vivado da floorplanning penceresinde pblock partition block tanımlanır
// rtl loc benzeri atributeler veya xdc komutlarıyla laan kısıtları ekleyebilirsiniz.

// pin assignment 
// ı/o seçimi
//fpga board tasarımında pinlerin hangi voltaj standardında lvds lvcmos 3.3 çalışacağı önemlidir.
// bazı ıo bankleri sadece 1.8 v çalışırken bazıları 3.3 v destekler
// pin planning tool
// vavado hnagi sinyali hangi phytsical pine atacağını belirleyebilirsiniz
// fpga pinleri özel netlere clock data reset bağlanır

// bank groping
// farklıvoltaj seviyeleri için her bank bir referans pin ve besleme vcco değerine sahip olabilir
// yükksek hızlı arabimler lvds gtp serdes de özel yerleştirme ister

//#örnek pin assignment xilinx
set_property PACKAGE_PUN G18[get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

// clk sinyali g18 pinie sabitleniyor

// dahili lojik analiz ILA Chipscope signaltap
// NEDEN İHTİYAÇ DUYARIZ
// FPGA İÇİNDEKİ SİNYALLERİ GERÇEK ZAMANLI İZLEMENİN PİN SAYISI VEYA ERŞİim zorluğu nedeniyle imkansız olduğu durumlarda dahili lojik analiz aracıdır.
// xilinx ILA INTEGRATED LOGİC ANALYZER
// ESKİDEN CHİPSCOPE DENİYORDU ARTIK VİVADO ILA IPSİ KULLANILIYOR
// tasarıma bir debug core eklenir izlenmek istenen sinyaller bu core bağlanır program çalışırken jtag üzerinden dalga formu çeklebilir

// ıla signaltap bloğunu ekleyip hangi sinyalleri izlemek istediğiniz sçeerisiniz
// dalga formları saklı rame yazılır pcye geri aktarılır

// online debug imkanı sunar
// fsm durumlarını veri akışını gözleyebilirsiniz
// çok fazla sinyal izlemek isterseniz alan veya timing sorunları oluşabilir

// ek test debug yöntemleri
// jtag hud  basit jtag interface ile register erişimi bazı taasımlarda custom jtag logic
// gpıo led debug kritik sinyalleri ledlere veya gpıo portların a yansıtmak kısıtlı gözlem imkanı sunar
// ıla genişletme pipeline aşamalarını internal bus sinyallerini fıfo doluluk seviyesini vs izleyebilirsiniz tetik trigger koşulları da tnaımlayabilirsiniz if data_in == 8'hff then capture 
// if data_in == 8'hFF then capture

// test sürecinde floorplanning ve ıla etkileşimi
// bazı kritik yolları ıla ile izlemek istiyorsanız ıla logic netşeri pipeline kelemenizi engeylleyebilir veya extra gecikme getirebilir
// timing closure zorluğu debug core ekledinizde lcok domaini frekansını tuttmrak zorlaşabilir bebuggable hale getirmek önemlidir.

//F) Özet ve Sonraki Konular
//Bu sohbetle:

//Floorplanning ve pin assignment konusunu,
//Dahili lojik analiz (ILA, ChipScope, SignalTap) kullanımını
//FPGA gerçekleme aşamasında debug imkânlarını

//Bir sonraki sohbetimizde, istersen:

//Bazı üst düzey tasarım örnekleri (ör. basit bir CPU çekirdeği, gelişmiş filtre tasarımı vb.)
//Yüksek seviye diller (HLS – High-Level Synthesis)
//veya “RTL Design Best Practices” şeklinde genel tavsiyeler üzerinde durabiliriz.
/// fsm fsmd pipeline multi clock 
// daha üst düzey tasarım örnekleri ve rtl tasarımınd aiyi uygulamalar best practices ayrıca dilersen hls  c'denhdl'e araçlarına kısaca değinebiliriz

// üst düzey tasarım örnekleri
// basit cpu çekirdeği soft processer
// fpga'de bir soft processor RISC benzeri tasarlamak mümkündür
// 5 aşamalı pipeline fetch decode execute memory write back
// register file alu kontorl ünitesi FSM 
//rısc çekirdeğinizi de fsmd pipeline mantığını birleştirerek yapabilirsiniz

//IF -> ID -> EX -> MEM -> WB

// her aşaamada pipeline registerların kulanılır kontrol ünitesi fsm opcode alıu işlemi bellek erişimi yapay zeka moddeli oluşturur 
// Linux üzerinde FPGA IP bloklarına driver entegre etmek, device tree girişi eklemek gerekebilir.
//SoC FPGA konsepti, CPU ve FPGA kaynaklarını tek çipte birleştirir.
//Yazılım (PS) ve donanım (PL) entegrasyonu, yüksek performans ve esneklik sağlar.
//Gelişmiş uygulamalar: gömülü Linux ile hardware acceleration, gerçek zamanlı kontrol, vb.
//E) Uygulama Örnekleri
//Donanım Hızlandırıcı (Hardware Accelerator)
//CPU, bir veri kümesini FPGA’ye gönderir, FPGA tarafında parallel/pipeline aritmetik işlem yapılır, sonuç geri döner. Örn: Kriptografi, Görüntü İşleme, Yapay Zekâ katmanları.
//Gerçek Zamanlı Kontrol
//CPU üzerinde işletim sistemi, PL’de hız gerektiren IO işleme.
//Örneğin motor kontrol, PL’de PWM jenerasyonu ve hassas zaman ölçümleri, CPU ise karar mekanizmalarını çalıştırır.
//Gömülü Linux + FPGA
//PL tarafında custom IP, Linux tarafında driver yazarak cihaza /dev/ veya sysfs üzerinden erişim sağlanır.

// axı gp master slave
// cpu dan fpga registerlarına basit MMIO erişimi için kullanılır
// high performance hp ports
// geniş veri bant genişliği mesela DDR doğrudan fpga tarafının erişmesi
// ACP cpu cache ile fpga arasındaki paylaşılan hafıza erişimiini koherent hale getirir.
// ınterrupt mekanizmaları
// fpga bir olay olduğunda cpuyu kesme interrupt ile uyarmak

// vivado fpga kısmının sentezi yerleştirme bitstream oluşturma
// sdk veya vtis ps tarafı için c kodu derleme elf dosyası oluşturma
// petalinux linux kernel device tree root file system oluşturma
// yazılım geliştirme ps
//c c++ ile uygulama geliştirililir derleyici gcc arm toolchain işletim sistemi linux veya baremetal environment
// fpga geliştirme pl 
// rtl veya hls ile mantık tasarlarnır
// ıp ıntregratror vivado veya platform designer kullanarak cpu fpga arabirimi ypaılandırılır

// petalinux soc eds
// xilinx tarafında petalinux hem yazılım hem fpga kısımlarını entegre build ve boot imajı üretme aşamalarında kullanılır

+-----------------------------+  PS (Processing System)
| Dual Cortex-A9             |  - DDR denetleyici, 
| L2 Cache, On-Chip Memory   |  - QSPI/NAND/SD vb. Boot
| Peripherals (UART, SPI,...)|  - Ethernet MAC, USB, vb.
+-------------+--------------+
|       AXI Interconnect     |
+-------------+--------------+
|       Programmable Logic   |  PL (FPGA tarafı)
|       (FPGA)               |
+----------------------------) SoC FPGA Nedir?
Temel Tanım

Aynı yonga (die) üzerinde bir CPU çekirdeği (ARM Cortex-A vb.) ve FPGA mantık alanını birleştiren entegre yapıdır.
Bu sayede işletim sistemi (örn. Linux) veya bare-metal uygulamalar CPU üzerinde çalışırken, yüksek hız gerektiren veya özel donanım hızlandırma gereken işlemler FPGA bölümünde gerçekleştirilir.
Avantajları

Düşük maliyet ve alan: Harici işlemci + FPGA yerine tek çip.
Yüksek Bant Genişliği: CPU-FPGA arasındaki veri yolu (AXI) içsel ve geniş bantlı, harici arabirimlere göre çok daha hızlı.
Gelişmiş IO: Yonga içi (PS – Processing System) periferik blokları (UART, I2C, SPI, Ethernet MAC vb.) CPU’dan kolayca yönetilir.
Örnek Aileler

Xilinx Zynq-7000 (Cortex-A9 tabanlı) ve Zynq UltraScale+ (Cortex-A53).
Intel Cyclone V SoC (Cortex-A9), Arria 10 SoC (Cortex-A9), Stratix 10 SoC (Cortex-A53).-+

