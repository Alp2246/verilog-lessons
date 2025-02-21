// FSM FİNİTE STATE MACHİNE TEMELLERİ MOORE MEALY VE TEMEL KODLAMA YAKLAŞIMLARI
// fpga iç kaynaklarını ve senkron tasarım ilkelerini konuştur. şimdi fsm kavramını ele alacağız
// fsmler dijital devrelerde kontol mantığını düzenlemek ve karmaşık durum akışlarını yönetmek içn kullanılır.

//FSM NEDİR neden kullanılır
// fsm tanımı bir fsm sınırlayıcı sayıda durumdan state oluşan ve girdi input ile mevcut duruma göre çıkış output üreten yeni durumlara geçiş yapan next state dijital kontrol yapısıdır.
// örnek kullanım alanları
// protokol denetimi UART SPI I2C
// veri akışı yönetimi DMA a bellek kontrolü
// sekanslı görevler butona basma senaryoları açılış sekansları
// kompleks kontrol akışları

// avantajı 
// durum geçişler istate transitions ile kontrolün basit ve düzenli tanımlanması
//zamanlama ve senkronizasyon kolaylığı
// büyük karmaşık işlemlerde modülerlik

// moore ve maly makineleri
// fsm tasarımında iki ana model vardır moore mealy temel fakrları
// moore makinesi
// çıkışlar yalnızca mevcut durumun state fonksiyonudur.
// durum diyagramında çıkış değerleri durumun içinde tanımlanır
// avantajı zamanlama açısından daha öngürülebilir çıkışlar bir sonraki clock kenarına kadar sabit kalır 
// mealy makinesi
// çıkışlar hem mevcut durum hem de girişlerin fonksiyonudur
// durum diyagramında oklar tansition üzerinde çıkış ifade edilir
// avantajı bazı durumlarda daha az durum sayısı ile aynı davranış elde edilebilir dezavantaj girişteki anlık değişim çıkışı clock beklemeden değiştitreiblir

// birçok uygulamada moore makineleri tercih eilir girişteki glitch veya anlık değişimlerin doğrudan çıkışa yansıma ihtimali azılır daha basit durum sayısı gerekibiielceği için bazen mealy kullanılır.
// sıralı devre olarak fsm genel yapı
//bir fsm temelde iki ana bileşenden oluş
// state refister durum kayırçıları
// mevcut durumu saklayan flip lfop kümesi
// her clock kenarında yen iduruma güncellenir
// kombinasyonel mantık
// next state logic mevcut durum ve girdi değerlerine göre gelecek durumu bleirler
// output logic moore da sadece durumdan mealyde durum girdi kombinasyonundan çıkış hesaplar
// blok diyagram moore için
     +---------------+
     |  Mevcut Durum | ----> (Moore) ----> Çıkış
     | (D flip-flop) |
     +---------------+
           ^    ^
           |    |
  Girdi ----+    +----> Kombinasyonel Mantık (Next State Logic)

// iki segmentli kodlama önerilen yaklaşım vhdl fsm kodlama yöntemi
// birçok tasarımcı fsmi iki süreç process şeklinde yazar
// register process saat kenarında durumu saklayan register
// next state output process kombinasyonel mantık hesapları next state çıkış

// moore fsm 3 durumlu sayıcı
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_example is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        inA : in   std_logic;
        outY : out std_logic
    );
end fsm_example;

architecture two_process of fsm_example is

    type state_type is /s0,s1,s2);
    signal current_State, next_state : state_type;

begin
  
  ---(1) register process : durum kaydedici
  process(Clk, reset)
  begin
        if reset = '1' then
            cırrent_state <= s0;
        elsif rising_edge(clk) then
            current_State <= next_state;
  end if;
end process;

-- (2) next state & output process kombinasoynel mantık
process(current_state, inA)
begin
    -- varsayılan atamalar
    next_state <= current_State;
    outY <= '0';

    case current_State is
        when S0 =>
            outY <= '0';
            if inA = '1' then
                next_State <= s1;
end if;

when s1 = >
    outY <= '1';
    if inA = '0' then
        next_State <= s2;
    end if;

    when S2 => 
        outY <= '0';
        if inA = '1' then
            next_state <= s0;
        end if;

    when others =>
        next_state <= s0;
end case;
end process;

end two_process;

// ilk process saat kenarınd acurrent_State güncelleniyor
// ikinci process current_State ve inA'ya bakarak next_State ve outY  hesaplanıyor
// bu örnekte bir moore fsm var çünkü out y sadece mevcut duruma bağlı kısmi olarak da girdi etkisi vamrış gibi görünüyor ama her clock çevriminde karar verilmiş oluyor

// üç segmentli kodlama eski yaygın yaklaşım
// 1 process mevcut durum register
// 2 process next state belirlenmesi kombinasyonel
//3 process output belirlenmesi kombiansyonel

// üç segment bazen analaşılırlığı artırabilir ancak çok fazla process de karmaşık oalbilir

// tek segmentli kodlama
// aynı process içinde hem saatli clocked hem de kombine kısımlar yazarız
// daha kısa kod gibi görünse de karmaşıklığı artar sentez ve hata ayıklama güçleşebilirç
// fsm tasrımında dikkat edilmesi gerekenler
// durumun kodlaması state encoding
// araçlar genelde otoamtik kodlar one hot binary gray
// elle kodlamak isterseniz type state _rtpe terine std_Logic_Vector kullanabilirsiniz.

// durum kullanılmayan kodlamalar
// fsmnin tanımlamadığınız durum kobinasyonlarına gitmesi gari sınuçlar odğrulabilir
// bazı araçlar safe fsm seçeneğ sunar when other => next_Stas te z? s0; gibi eklemeler yaparak durumu toplarlyabilirsiniz
// zamanlama fsm çıkışının senkron olmasına özen gösterin moore genelde daha güvenli
//eğer mealy gerekiyorsa girişlerin metastabilty riskini göz önünde bulundurun gerekirse senkronizasyon
// asenkron sinyaller
// fsm'de kullanılacak tüm giriş sinyalleri mümkünse clock domain içindeki flip floplardan gelsin veya önce senkronize edilsin
// asenkron girişlero doğrudan fsme bağlamak metastabilite riskini artıırır.

//OUTz HEM CURRENT_sTATE HEM DE İNa'YA BAĞLI

architecture mealy_fsm of fsm_example is
    type state_type is (s0, s1);
    signal current_state
    signal outZ_reg İ std_logic := '0';
begin

    process(clk,reset)
    begin
        if reset = '1' then
            current_state <= s0;
        elseif rising_edge(Clk) then
            current_state <= next_state;
    end if;
end process;

process(current_state, inA)
begin
    next_State <= current_state;
    outZ_reg <= '0';

    case current_State is
    when s0 =>
        if inA = '!' then
            next_state <= S1;
            outZ_Reg <= '1'; - mealy: giriş ) 1 anında çıkış 1
end if;

when S1 =>
    if inA = '0' then
        next_State <= S0;
    else 
        outZ_reg <= '1';
    end if;

when others =>
    next_State <= s0;
end case;
end process;

--MEALY ÇIKIŞI 
outY <= outZ_reg;

end mealy_fsm;

// gördüğün gibi outz reg ataması girdiye naınd atepki gösterebiliyor durum dayanıklı ama mealy mantığına uygun

// fsm kavramını 
// temel kodlama yaklaşımlarını 
// tasarımda dikkat edilmesi gereken noktaları

// fsmin veir yolu data path ile beraber kullanılması fsmd mimarisine giriş yapacağız asmd diyaglar sistem tasarımlarına değişeneceğiz dağha karmaşık işlemlerin nasıl yönetilidğini anlamak iç