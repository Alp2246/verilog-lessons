// BİR ÖNCEKİ SOHBETİMİZDE FPGA GENEL ÇERÇEVESİİN BASİT BİR BLİNK örneğini eele almıştır. şimdi fpgalerin içinde yer alan temel donanım kaynakları ve dijiytal tasarım ilkeleri üzerinde duralım.

// CLB configurable logic block veya LAB 
// iç yapı lut lok up table flip flop ff bve bazen ek yapı taşlarından oluşur.
//görev temel mantık fonksiyonlarının and or sor lut üzerinden gerçekleştirilmesi ve bu lut çıkışlarının ff'ler ile senkron saklanması

//LUT look up table
// bir lut basitçe bir değer tablosu gibi çalışır mesela 6 girişli LUT 64 SATIRLIK BİR TABLOYU İFADE EDER. gİRİŞ KOMBİNASYONUNA GÖRE LUT ÇIKTISI SEÇİLİR.
// fpganin esnekliğini sağlayan temel bileşendir.

// flip flop ff / register
// senkron bellek elemanıdır clock kenarında veri güncellenir.
// fpga içinde genellikle her lutun yanında veya clb içinde 1 2 adet ff bulunur

//DSP blokları
// özellikle çarma toplama gibi yüksek hızlı aritmetik işlemlere özel donanım bloklarıdır.
// xilinx fpgalerde dsp48 blokları 25 çarpı 17 multipler akümülatör bulunur
// avantaj büyük boyutlau çarpma toplama işlemlerini lut yerine bu bloklarda yaparak hızı artırır lut kaynağını obşaltır

// blokck ram bram ve ultraram
// block ram genelde 17 kbit veya 36kbir entegre sram blokları
// ultraram azı ileri seviye fpgalerde daha büyük kapasite 288 kbit sunar
// avantaj veri depolama fıfo tampon gibi uygulamalar için dahili ve hızlı bellek alanı sağlar

// ı/o blokları ıob 
//foganin giriş çıkış pinlerini kontrol eden bloklardır.
// özelliği seviye çevirici lvds lvcmos ddr desteği kalibrasyon vb özellikler içerir
// clock yönetim blokları pll MMCM
// saat clock sinyallerini çarpan veya bölen pll ya da mmcm mixed mode clock manager gibi kaynaklar içerir
// daha kararlı saat sinyali farklı fazlar ve frekanslar üretmek

//fpga üzerinde tasarım ilkeleri senkron tasarım
// kural saat clock sinyali ile tetiklenen ffleri kullanarak tüm mantık işlemlerini bu ffler arasına yaymak
// neden önemli zamanlama analiz i fpgadeki en kritik kısımdır senkron tasarım zamanlama setup hold gatalarını azaltır ve tasarımın ölçeklenebilirliğini arıtıtrır.

// kombinasyonel mantığı ffler arasınd apaylaştırma pipelining
// amaç yüksek hız yani daha yüksek saat frekansı elde etmek büyük bir mantık bloğunu birkaç aşamaya pipeline stage bölüp her aşama FF kullanarak kritik yol critical path  gecikemsini kısaltmak

// reset stratejisi
// senkron reset vs asenkron reset birçok fpga tasarımında senkron reset terich edilir zamanlama açısından dahak ontrollü olur 
//// resetin kullanımı gereksiz tüm fli p floplar ırest etmekten kaçınmak alan ve kaynak kullanımını optimize eder
// kaynak paylaşımı ve dsp bloklarının kullanımı a
// aynı çarpma işlemini farklı zamanlarda kullanıyorsunaız bir dsp bloğunu paylaştırabilirsiniz time multlexing
// lut israfını önler hız artışı veya alan optimizasyonu sağlar
// timing constraints zamanalama kısıtları tasarımınızın istenen saat frekansında çalışabilkmesi için constraint kısıtlar tanımlamak gerekir örneğin create_clock set_input_delay set_output_Delay gibi komutlarla giriş/çıkış gecikmeleri ayarlanır.
// araç bu kısıtlara uymak için yerleştirme placement ve yönlendirmeyi routing optimize eder 

// vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter4 israfınıPort (
    clk : in std_logic;
    reset : in std_logic;
    q     : out std_logic_vector(3 downto 0)

);
end counter4;

architecture rtl of counter4 is
    signal count_Reg : unsigned(3 down to 0) := (others =Z '0');
begin
  if reset = '1' then
      endcount_reg <= (others => '0');
  elsif rising_edge(clk) then
    count_reg <= count_reg + 1;
 end if;

end process;

q <= std_logic_Vector(count_reg);

end rtl;

// açıklama count_ reg sinyali unsigned 3 downto 0 tipinde
// reset aktifken örnekte 1 kabul edilmiş sayaç sıfırlanır
// elfis rising_Edge(clk) satırı pozitif saat kenarında sayacı bir arıtıtrır
// sentez sonucu fpga içerinse bir tane 4 bitlik ff grubu register ve ek olarak 4 bitlik tam toplayıcı adder veya lut ile gerçekleştirilen toplama mantığı 

// özel notlar ipuçları
// vhdl'de türler signed unsigned std?Logic std_logic_Vector/
// unsigned ve signed sayısal işlemler için direkt destek sunar 
// std_Logic_Vector ise saf bit vektörüdür toplama gibi işlemler için önce dönüşüm gerekir
// verilgo c benzeri söz dizimine sahip daha sade bir dil olarak görülebilir
// vhdl güçlü tip kontrolö daha katı sözdizimi sunar hu hata ayıklamada avantajlı olabilir
///performans çok kritikse aynı işlemi parlael modüllerle çoğaltarak hız kazanabilirim alan maliyeti artar
// fpga aynı işi tekrar tektar yapan kısımları tespit ederek paylaşımlı kaynak oluşturabilirsiniz.

//sıralı devrelerin FSM FİNİTE STATE MACHİNE YEMELLERİNİ KONUŞACAĞIZ BU KAPSAMDA 
// FSM NEDİR NERELERDE KULLANILIR
// MOORE VE MEALY MAKNİESİ ARASINDAKİ FARKLAR 
// TEMEL BİR FSM NASIL KODLANIR SENTEZLENİR
// AYRICA TASARIMI BÜYÜTMEYE BAŞLADIĞIMIZDA HİYERARŞİ TOP DOWN VE BOTTOM UP YAKLAŞIMINI VE FSM VERİ YOLU DATA PATH FSMD KAVRAMINI ÖZETLEYECEĞİZ


