module top_static (
    input wire clk_100mhz,
    input wire rst_n,
    output wire led_Out
    // ... diğer ı/o'Lar
);

// BU MODÜL İÇİNDE RECONFİGURABLE PARTİTİON GİDECEK SİNYALLERİ TANIMLAYALIM
// örneğin tooggle out reconfigurable partitiondan gelen sinyal olsun

wire toggle_out;

// reconfigurable partition ınstantiation
// vivado placeholder veya black box olarak tnaımlanabilir
rp_container rp_inst (
    .clk (clk_100mhz),
    .rst (rst_n),
    .toggle_Out (toggle_out)
    // ek arabirim sinyalleri
);

// led bu sinyali verelim veriyoruz
assign led_Out = toggle_Out;
endmodule

// rp_Container adlı bir alt modül reconfigurable partition için placeholder görevi göreviyor

// reconfigurable modül örneği blinker 1hzz rm1

module blinker_1hz(
    input wire clk,
    input wire rst,
    output wire toggle_out
);

    reg[24:0] counter;
    always @(posedge clk or negedge rst) begin
      if (!rst)
         counter <= 25'd0;
      else
        counter <= counter + 25'd1;
    end

    // 1 hz blink için: assuming clk= 100 mhz
    // 100e6 ~ 2^26.57 civarı
    // basitçe counter'in 25 veya 26 bitini toggle_out yapabiliriz
    assign toggle_out = counter [24];
endmodule

//reconfigurable modül örneği blinker 4 hz rm2

module blinker_4hz (
    input wire clk,
    input wire rst,
    output wire toggle_out
);

    reg [22:0] counter;
    always @(posedge clk or negedge rst) begin
        if (!rst)
            counter <= 23'd0;
        else
            counter <= counter + 23'd1;
    end

    // 4 Hz blink ~ 25e6 clock darbesi => 2^24.57 civarı
    assign toggle_out = counter[22];

endmodule
// yukarıdaki kodlarda sadece sayıcı boyutunu ve ibt indeksini farklı ayarladık iki farklı blink frekansı oluşturduk

// rp_container.v
// wrapper modül gibi davranır. aslında tam pr flow da bu container modül black box oluyor ve blinker_1hz veya blinker_+hz netlisti oraya yerleştiriyor

// vivadodaki adımlar(özet)
// proje oluşturma ve rtl ekleme
// tüm .v dosyalarını vivado projesine ekle
// reconfigurable partition tanımlama
// rp_Container HERARŞİK İNSTANTİATİONI SEÇ SET AS RECONFİGURABLE PARTİTİON
// VİVADO BU ALT MODÜLÜN PBLOCK FLOOPLAN BÖLGESİNİ ATAYACAK
// satik tasarım sentezi
// satik kısım top_Static rpc container black box şeklinde sentezlenir
// yerleştirme yönlendirme place & route ypaılrı bu sıarda reconfigurable bölge ayrılmış olarak kalır

// rm reconfigurable module projeleri
// blinker_1hz blinker_4hz modüllerini out of context ooc projelerde sentezle
// netlistini pblock içine implement eder her biri çin partial bitstream oluşturulur

// bitstream üreritmi
// full bitstream statik + varszayılan rm blinker_1hz
// partial bitstream alternative rm bunu rp bölgesine yüklemek için kullanırız
// pr konfigürasyonu
// fpga jatag veya bir axı ıcap sürücüsü üzerinden blinker 4h zpartial bitstream yükletrisn

// jtah vivado hardware managerden partial bitstream seçip partiak reconfiguration işarerleterek yüklemek

// ıcap ve pcap zynq soc fpga işlemci ps üzerinden pr bit dosyasını dahili hafızadan yükleyebilirsin
// xilinx prc ıp gibi modüller tma otamatik akış sağlar
// sırayla farklı rm 
//Gerektiğinde “blinker_4hz” → “blinker_1hz” → “farklı RM” vs. ardışık yükleme yapılabilir.

// pr süresi arayüz hızı jtag mi 100 mhz axı bağlı
// daha büyük pblock = daha büyük btstream = daha uzun load süresi

//Statik Kısma Etki
//Eğer doğru tasarlandıysa, statik kısım PR sırasında çalışmaya devam eder.
//Zamanlama aşımlarından kaçınmak için “bus macros” veya “routed bus macros” gibi yöntemler (eski ISE flow) veya şimdiki “reconfigurable partition pins” yaklaşımı gereklidir
//Uygulama İpuçları
//Basit Interface
//Reconfigurable modüllerin statik kısma minimum sayıda I/O sunması, tasarımı kolaylaştırır.
//Her RM Aynı Boyutta
//Tüm RM netlist’leri aynı boyutta (ya da en azından statik interface pin sayısı/isimleri) olmalı ki PR sırasında çakışma olmasın.
//Güç Yönetimi
//PR modülü devre dışıyken güç tasarrufu yapılabilir mi? Bazı FPGA modelleri kısmen destekler.

//Statik üst modül (clock, reset, I/O),
//Bir reconfigurable partition (rp_container),
//Birden fazla reconfigurable module (blinker_1hz, blinker_4hz),
//Vivado’da sentez/yerleştirme, partial bitstream üretimi,
//Çalışma sırasında partial bitstream yüklemesi.

// aes hızlandırıcı dsp filtesi bu şekilde düniştürülür
// bitstream şifreleme konunsa geçelim fpga tarafınd abitstream koruması ve secure boot yaklaşımlarını ele alacağız
//Şimdi FPGA Güvenliği başlığı altında, özellikle Bitstream Şifreleme ve “root-of-trust” yaklaşımlarını özetleyelim. Bu konu, “IP koruması” ve “sahada (field) güvenli güncelleme” gibi kritik senaryolar için önemlidir.

//A) FPGA Güvenliği Neden Önemli?
//Telif ve IP Koruması

//Geliştirdiğiniz FPGA tasarımı (bitstream), fikri mülkiyeti içerir. Bu bitstream’in çalınması veya tersine mühendislik (reverse-engineering) yapılması istenmez.
//Sahada Donanım Güncellemesi

//FPGA’ler, sahada yazılım gibi güncellenebilir (bitstream yüklenir). Bu güncellemelerin güvenli yapılması ve kötü niyetli bitstream’lerin yüklenmesinin engellenmesi gerekir.
//Sistem Bütünlüğü ve Gizlilik

//Bazı uygulamalarda (savunma, kritik altyapılar, finans vb.) FPGA tasarımıyla ilgili veriler gizli kalmalı ve devre manipüle edilmemeli.
//B) Bitstream Şifreleme Mekanizması
//1) Temel Prensip
//FPGA üreticisi (Xilinx, Intel) donanımda bir anahtar deposu (key storage) ve dekript modülü sağlar.
//Bitstream, geliştiricinin belirlediği özel bir anahtar (AES-256 vb.) ile şifrelenmiş hâlde dağıtılır.
//FPGA, boot veya konfigürasyon sırasında dahili anahtarı kullanarak bu bitstream’i çözer (decrypt) ve LUT/FF yapılandırmasını belleğe yükler.
//Böylece bitstream, dışarıdan bakıldığında sadece şifreli bir dosyadır, tersine mühendislik zorlaşır.
//2) Anahtar Saklama
//Xilinx: Bazı FPGA’lerde eFuse veya battery-backed RAM (BBRAM) yöntemiyle anahtar saklanır.
//Intel: Benzer şekilde eFuse veya dâhilî OTP (One-Time Programmable) alan sunar.
//Bu anahtar, FPGA’nin silisyumunda gömülü şekilde bulunur veya “programlama esnasında yakılır”, dışarıya çıkartılmaz.
//3) Şifreli Bitstream Oluşturma
//V/ivado’da “Enable Bitstream Encryption” seçeneği, Intel Quartus’ta “Encrypted SOF” gibi seçenekler vardır.
//Kullanıcı bu aşamada anahtarı (ör. 256-bit) girer veya harici bir key dosyası sağlar.
//Araç, bitstream’i AES algoritmasıyla şifreler.
//C) Sahada Güvenlik ve Boot Süreci
//Secure Boot (SoC FPGA)
//Xilinx Zynq / Zynq Ultrascale+ veya Intel SoC FPGA (Cyclone V SoC vb.) gibi çiplerde, hem işlemci (PS) tarafında hem FPGA (PL) tarafında bir secure boot zinciri oluşturulabilir.
//İşlemci kendi ROM kodundan başlayarak (on-chip bootloader), dijital imza denetimi ve bitstream şifre çözümü yapar.
//Bu sayede sahada FPGA bitstream’i yüklenirken veri bütünlüğü ve gizlilik korunur.
//ICAP / PCAP Üzerinden Güvenli Yükleme
//Sahada kısmi veya tam bitstream yükleniyorsa, yine şifrelenmiş format kullanılır.
//FPGA dâhilî “decrypt engine” bu veriyi açar ve programlar.
//Açık ve Gizli Riskler
//Anahtarın sızması veya “side-channel attack” (güç tüketimi, EM sızıntısı vb.) gibi yöntemlerle FPGA içi anahtarın elde edilmesi her zaman bir risk oluşturur.
//FPGA üreticileri, ek “anti-tamper” mekanizmalar (savunma amaçlı) sunabilir.
//D) Tersine Mühendislik (Reverse Engineering) ve Korumalar
//Bitstream Formatı

//Şifreleme yoksa, bitstream formatı bir dereceye kadar çözümlenebilir ve LUT bağlantıları üzerinden tasarım anlaşılabilir.
//Şifreli bitstream, bu tersine mühendislik çabasını çok daha zor hâle getirir.
//Readback Koruması

//Bazı FPGA modelleri, “readback” özelliğiyle FPGA konfigürasyonunu dışarı okumanızı kısmen destekler. Ancak şifreli bitstream’de “readback” ya kapatılır ya da şifreli hâlde kalır.
//Böylece devre çalışırken LUT içeriğini direkt öğrenmek engellenir.
//E) Donanımsal IP Koruma ve Lisanslama
//Soft IP vs. Encrypted Netlist

//FPGA vendor’larının “encrypted HDL” formatı (ör. Verilog/VHDL kaynaklarını şifreli saklamak) veya “netlist-based IP” yöntemleri kullanılabilir.
//Geliştirici, son kullanıcının FPGA projesine IP eklemesini sağlar ama IP’nin iç mantığı korunaklı kalır.
//Runtime Lisans Kontrolü

//Bazı gelişmiş senaryolarda “license check” mantığı FPGA içinde gömülü olabilir, lisanssız bitstream kısıtlı çalışır.
//Ticari FPGA IP modüllerinde vendor’ların benimsediği yöntemler olabilir.
//F) Uygulama Senaryosu: Savunma veya Hassas Projeler
//Diyelim ki bir askerî drone veya kritik kontrol sistemi FPGA tabanlı çalışıyor. Bu sistemin bitstream’i sahada güncellenebilir.
//Güvenlik Gereklilikleri:
//Kim yükledi, hangi sürüm, dijital imza doğrulaması, sahte bitstream engeli.
//Yüklenen bitstream şifreli, FPGA içi anahtar güvenli saklı.
//Sonuç: Sistemin devre tasarımını reverse-engineer etmek çok zor, hem de yabancı ya da kötü niyetli bitstream’in yüklenmesi engelleniyor.

//G) Sonraki Konular
//Bu sohbetle, Bitstream Şifreleme ve FPGA güvenliğinin ana hatlarını ele aldık:

//Neden bitstream şifrelenmeli, anahtar nasıl saklanıyor, sahada güvenli yükleme nasıl oluyor?
//Saldırılara karşı hangi yöntemler kullanılıyor?