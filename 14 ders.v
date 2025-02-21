//Bu kez, FPGA’lerin makine öğrenmesi (ML) ve yapay zekâ (AI) hızlandırma alanındaki kullanımına genel bir bakış sunacağız. Son yıllarda hızla gelişen bu alanda 
//FPGA’lerin nasıl konumlandığını ve hangi tür uygulamaların öne çıktığını tartışacağız.

// neden fpgalerde ml aı
// paralel işleme ml özellikle ypaay sinir ağları yüksek derecede paralellik içerir fpgalerde hesaplama birimleri dsp blokları lut paralelce çalıştırılabilir

// esneklik
// asıc tabanlı hızlandırıcılar tpu gpu asıc sabit mimari sunarken fpga tasarımını istediğiniz zama güncelleyip farklı ağ mimarilerine uyarlayabilirsiniz

// güç verimliliği fpga spesifik işlemleri tamsayı çarpma toplama enerji açısından verimli şekilde yürütebilir
// dınanımsal özelleştirme veri yolu genişliği sabit nokta fixed point kayan nokta floating point veya karma yaklaşımlar 8 bit quantization esnekce uygulanabilir

// temel uygulamalar
// sinir ağı ileri besleme ınference
//dll genişbant yapınca düzeliyor
//örnekleme frekansının kararlığlıını ölçülebilir.
//özellikle CNN convolutional neural network katmanlarında matris çarpmaları multiply accumulate yoğun biçimde kullanılır
// fpga sabit nokta 8 bit 16 bir hesaplamayla bu katmanları hızlandırabilir.

// görüntü işleme ve nesne tanıma
// kameradan gelen veriyi fpga de gerçek zamanlı ileyip sinir ağında feature extraction yapmak
// yolo tabanlı nesene tespiti fpga inference hızlandırıcı

// RNN LSTM Transformers
//doğal dil işleme veya zaman serisi analizinde kullanılan katmanlar da fpga 'de hızlandırılabilir
// bu ypaılar cnn kaday yaygın olmasa da attention mekanızmalarında fpga ile deneysel çalışmalar mevcut

// el yazması RTL
// mac bloklarını veri akışını bvuffer düzenini elle tasarlayabilirisinz 
// model karmaşıksa rtl seviye çok büyük olur
// hls high level synthesis 
// c c++ şeklinde matris çarpma veya vnn katmanları kodlayıp hls aracıyla otamtik rtle dönüştürmek
// xilnix vitis hls pipeline unroll optimizasyonlar yapılır

// framework entegrasyon
// xilinxin vit aı tensorflow caffe modellerini fpga hızlandırıcı ıpsine dönüştürme imkanı sunar
// amaç yazılım geliştiriceleirn düşük seviyeye inmeden fpga hızlandırmaısndan yararlanması
// kütüphaneler ve ıp corelar fpga vendorları hazır matris çarma ıp core veya cnn ıp core sunabilir

// basit cnn katmanı convolution
// giriş feature haritası m x m boyut çoklu kanal 3 kanallı rgb
// çekirdek filtre k boyutlu 3 x 3 5 x 5 her giriş kanalına bir ağırlık matrisi
// çekirdek x giriş pikselleri toplama aktivasyon ReLU
// fpga de her clockta bir pikselin çarpım toplamını yapmak ve devreyi pipeline paralel kurara r ibrden çok pikseli aynı anda işlemek
// performans metriği
// tops tera operations per second cinsinden ölçülür
// fpga de saat frekansı gpu kadar yüksek olmasa da katı parallelik ile performans elde edilebilir.

// matris çarpma mxn nxp şeklinde bir fonksiyon

// örnek pseudo code xilinx vitis hls stili:
void matrix_mul(const int A[M][N]),
                const int B[N][P],
                int C[M][P] {
#pragma HLS PIPELINE
    for(int i = 0; i < M; i++)
     for(int j = 0; j < P; j++){
        int sum = 0;
        for (int k = 0; k < N; k++){
#pragma HLS UNROLL factor_UNROLL_FACTOR
        sum += A[İ][k] * B[k][j];
        }
        c[i][j] = sum;
        }
     }
 }

// # pragma HLS PIPELINE ve #pragma HLS UNROLL gibi direktiflerle döngüleri pipelinelayabilir paralel işleyebiliriz
//HLS aracı elverişli pipeline ve veri akış şeması çıkaraır LUT DSP47 BRAM kullanımını optimize eder

//önemli noktalar
//quantization(bit genişliği)
// 8 bit sabit nokta mı 16 bit mi yoksa floating point mi fpga de sabit nokta genelde alan ve güç açısından avantajlı
// bellek bant genişliği
// büyük cnnlerde veriye hızlı erişim gerek DDR  bellek BRAM cache mekanizmaları planlanmalı
// veri yeniden kullanımı data reuse arttırarark bant genişliğni iverimli kullanmak mümkün
// pipeline derinliği 
// cnn katmanlarında convolutio aktivasyon pooling aşamalarını arka arkaya pipeline yapabilirsinz latency artsa da throughput yükselir
//resource dsp bram
// katman boyutu kanal sayısı büyüdükçe fpga kaynak tükeitmi hızla artar
// rosoruce sharingveya kısmi reconfiguraion teknikleri düşünülebilir

// fpga ml uygulamaları örnek alanlar
// nesne tanıma / algılama otonom araçlar ve günenlik kameraları
// tıbbi görüntü analizi mrl ulrason 
// ses sinyl işleme konuşma tnaıma gürültü filtresi
// finans uygulamaları risk analizi algoritmik ticaret

// sonraki adımlar
// fpgalerin ml al alanındaki konumunu tasrım yöntemlerini rtl hls framewor ktemel dikkat noktalarını özetledik
// vitis aı dnndk openvıno patlformlara bak
// özel cnn ıp core inceleyebilir parametrelerle katman boyutu bit gneişliği oynarayarak bir protoip oluştur

//RTL Projelerini Derinlemesine İnceleme

//Mevcut notlarımızı, taslak projeleri, “kod incelemesi” (design review) şeklinde ele alabiliriz.
//Örnek: Daha ayrıntılı bir FIR filtre, FFT blok veya AES şifreleme modülü incelemesi.
//Partial Reconfiguration (Kısmi Yeniden Konfigürasyon)

//FPGA’de çalışma sırasında seçili bir bölgeyi yeniden yükleme:
//Yöntem, araç (Xilinx PR flow, Intel PR flow)
//Uygulama örnekleri (çoğul hızlandırıcıların sırayla yüklenmesi vb.).
//Gelişmiş Test ve Debug Teknikleri

//ILA/ChipScope/SignalTap kullanımına daha pratik örnekler
//“Hardware-in-the-loop” test senaryoları
//Otomatik test sistemleri
//Ek Güvenlik (Security) Konuları

//Bitstream şifreleme, FPGA’de root of trust
//Bazı güvenli tasarım uygulamaları (dijital IP koruması vb.)
//Kripto hızlandırıcıların (AES, SHA, RSA) RTL örnekleri
//Gerçek Zamanlı Sistemler ve Zaman Determinizmi

//FPGA’yi “real-time” sinyal işleme veya kontrol sistemlerinde kullanmak
//Low-latency pipeline ve jitter kontrolü
//Ek Yüksek Hız Arabirimleri

//USB 3.0/3.1 IP, MIPI CSI/DSI (kameralar, ekranlar)
//erDes hatlarında deskew / multi-lane bonding
//Dahili Protokoller: AXI4, Avalon, Wishbone

//Bu haberleşme protokolleri arasındaki farklar ve tasarım örnekleri
//Custom IP oluştururken AXI4-Stream vs. AXI4-Lite vb.
//HLS İlerlemesi ve Uygulama

//Bir “C tabanlı” küçük kodu alıp Vitis HLS veya Intel HLS ile dönüştürme
//Koştuğumuz pipeline, unroll, resource usage sonuçlarını analiz
//Soru-Cevap / Derleme

//Önceki sohbetlerde kısaca değindiğimiz konuların hepsini toparlayan veya senin özel merak ettiğin noktaları derinleştirecek oturumlar
//Final Özetler ve Yol Haritası

//Ek kaynak önerileri
//Kariyer perspektifi (FPGA mühendisi olarak endüstride neler yapılır vb.)
//B) Nasıl İlerleyelim?
//11 (ya da 21) Sohbetlik planı, her sohbeti yukarıdaki maddelerden birine veya birden fazlasına ayırarak ilerlemek şeklinde olabilir.
//Arada senin soru-cevap yapmak istediğin spesifik noktalar olursa, ayrı bir sohbet açıp onlara odaklanabiliriz.
//Örnek 11 Sohbetlik Plan (30 Hedefliyorsak)
//(Sohbet 20) Partial Reconfiguration – Temel Kavramlar
//(Sohbet 21) Partial Reconfiguration – Örnek Akış
//(Sohbet 22) Güvenlik ve Bitstream Şifreleme
//(Sohbet 23) Daha Derin Bir FIR/FFT Uygulaması
//(Sohbet 24) Gelişmiş Test/Debug Teknikleri (ILA vb. örnek)
//(Sohbet 25) AXI4 Protokolü – Detay ve Kod Örnekleri
//(Sohbet 26) HLS ile Basit Bir Proje – Pipeline/Unroll Uygulaması
//(Sohbet 27) Gerçek Zamanlı Sistemler ve Jitter Kontrolü
//(Sohbet 28) Soru-Cevap / Derinleştirme Oturumu
//(Sohbet 29) Final Örnek – Gömülü Sistemle Entegrasyon
//(Sohbet 30) Kapanış, Özet, Ek Kaynaklar
//Örnek 21 Sohbetlik Plan (40 Hedefliyorsak)
//Aynı başlıklara ek olarak:
//Daha kapsamlı “Security”, “Multi-lane SerDes”, “Machine Learning – DNN pipeline” vb. 10 ek sohbet ekleyebiliriz.
//Ayrıca “design review” stilinde bir-iki sohbet yapıp, uzun bir RTL kodu adım adım okumak, potansiyel sorun noktalarını tartışmak mümkün.
