// hierarchical katmanlı tasarım ve parametrik modüller
// çoklu saat atsarımını ve senkronizasyon tekniklerini konuştuk. şimdi hieararchical katmanlı tasaarım kavramına geçip parametrik modüllerin verlogda nasıl yazılabileceğini inceleyim

// moduler yaklaşım
//sistemi mantıksal anlamda alt bloklara submodule bölerek tasarlamak
// örneğin uart modülü ı2c arayüzü ana kontrol fsmi gibi ayrı modüller

// top üst modül 
// alt modülleri instantiate örneğin uart u0(...) eder birbirine bağlar
// sistem seviyesi sinyallerin yönetimini yapar

// neden kullanılır.
// anlaşılabilirlik: küçük parçalara bölmek kodu daha okunur kılar
// tekrar kullanılabilirlik reusable IP
// BÜYÜK EKİP PROJELERİNDE FARKLI MÜHENDİSLER ALT MODÜLLERDEN SORUMLU OLABİLİR.

// ALT MODÜL VE TOP MODÜL
// alt modül submodule basit bir 4 bit sayıcı

module counter4 (
    input wire clk,
    input wire reset,
    output reg [3:0] q
);

    always @(posedge clk or posedge reset) begin
      if (reset)
         q<= 4'd0;
      else
         q <= q +1;
    end
endmodule

module top_design (
    input wire clk,
    input wire reset,
    output wire [3:0] q0,
    output wire [3:0] q1
);

    // alt modül 1
    counter4 c0 (
        .clk (clk),
        .reset (reset),
        .q    (q0)
    );

    // alt modül 2
    counter4 c1(
        .clk (clk),
        .reset (reset),
        .q    (q1)
    );

endmodule

//bu şekilde top_Design iki counter4 modülü içerir. her biri aynı kod ama yrı register kaynağı kullanır.

// parametrik tasarım verilog parameter
// amaç
// modülün bit genişliği veya başka özelliklerini parametre üzerinden ayarlanabilir yapmak
// mesela bir çarpma modülünün 8 16 veya 32 bit versiyonlarını tek bir kodla üretebilmek

// verilogda parameter
// modül tanımında parameter ifadesiyle varsayılan değerler belirlenir
// örnek parameter WIDTH =8;
// instantiation sırasında #(12) gibi yazarak farklı bir değer geçilebilir

// parametrik sayaç

module param_counter #(
    parameter WIDTH = 8
)(
    input wire clk,
    input wire reset,
    output reg [WIDTH-1:0] q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= {WIDTH{1'b0}}; // 0'a set
        else
            q<= q + 1'b1;
    end
endmodule

// varsayılan olarak WIDTH = 8.



module top_param (
    input wire clk,
    input wire reset,
    output wire [7:0] q_small,
    output wire [15:0] q_large
    );

    // 8 bit sayaç (varsayılan parameter)
    param_counter c_small(
        .clk (clk),
        .reset (reset),
        .q     (q_small)
    ); 

    // 16-bit sayaç(parametreyi değiştiriyoruz)
    param_counter #(.WIDTH(16)) c_large(
        .clk   (clk),
        .reset  (reset),
        .q      (q_large)
    );

endmodule

// c_small 8 bitlik sayaç c_large 16 bitlik sayaç
// generate blokları
// amaç for veya if gibi yapıları kullanarak birden fazla altm odül veya mantık kopyası oluşturmak
// verilog söz dizimi 2001 standardından itibaren
// generate ... endgenerate blokları içinde genvar kullanarak döngü yazabilirsiniz
// N adet 8-bit sayaç oluşturma

module multi_counters #(
    parameter N = 4
)(
    input wire clk,
    input wire reset,
    output wire [N*8-1:0] q
);

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_count
            param_counter #(.WIDTH(8)) c_i (
                .clk (clk),
                .reset (reset),
                .q    (q[(i+1)*8 -1 : i*8])
            );
        end
    endgenerate
endmodule

// bu kod n adet 8 bit sayaç instantiate eder ve çıktıları q vektörüne yan yana dizilmiş şekilde bağlar

// Design partition mantıksal bölümleme

//Physical Partition – Farklı FPGA bölgelerine veya farklı çiplere yerleştirme (daha ileri seviye).
//Logical Partition – Kodun mantıksal olarak alt dosyalara/modüllere ayrılması.
//Takım Çalışması – Büyük bir projede her alt modül ayrı bir geliştiriciye atanabilir.
//Derin Hiyerarşiler – Bir modülün içinde başka modüller, onların içinde başka modüller…

// sentez farklı dosyaları top ve alt modüller tarar hangi modülün hangisini instantiate ettiğini öğrenir en osunda tek bir netlist üretir.

// fpga build flow
// top module --> sentez ---> place & route -----> bitstream.
// hiyerarşi tasarımı düzenlı kılar ama final aşamada tek parça netlist oluşur

// hierarchical tasarım sistemi alt modüllere ayırıp top modül üzerinden yönetmek
// parametrik modüller parameter genişlik buffer size gibi değişkenlerle kodu esnekleştirmek
// generate blokları tekrarlı instantiate veya mantık kopyası için kullanılırç

// testbench yazma ve kod doğrulama(simulation) süreçlerine göz atabiliriz. pacages ve kod orgonizasyonu konularına da değinebiliriz.