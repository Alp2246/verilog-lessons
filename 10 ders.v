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
