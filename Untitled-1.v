// şimdi FSM'İN sadece kontrol tarafını control path değil bir data path veri yolu ile birlikte nasıl çalıştığını inceleyelim.
/// bu bütünleşik yapıya genelde fsmd finite state machine with datapath adı verilir.

// fsmd nedir fsm contorl path ve data path toplayıcılar çarpıcılar kayıtlar vb elemanları barındıran kısım birleşiminden oluşan bir yapıdır.
// amaç karmaşık veya çok adımlı bir işlemi sayısal filtre şifreleme modülü prtokol işlemcisi parçalara bölmek ve her adımı kontrol etmek için fsm kullanılır.
// data path ise o adımda yapılması gereken işlemi toplama çarma vs gerçekleştirir.

+-------------------+
Kontrol ---> | Next State Logic | 
(Girişler)     |  (FSM)           | ---> outX
            +-------------------+
                 |    ^
                 v    |
            +-------------------+
  Data_in -->| Data Path (Register & ALU vb.) |--> Data_out
            +-------------------+

// control path fsm hangi adımda state olduğumuzu data pathin gangi işlemi yapacğaını belirler
// data path registerlar alu çarma modülü operasyonları yapar.

// register transfer metodolojisi
// adım adım işlemler veri kayıtlardan register diğer kayıtlara belirli bir saat çevriminde transfer edilir bu sırada aritmetik veya mantık işlemleri ypaıır.
// zaman paylaşımı time multiplexing örneğin tek bir çarma modülünü farklı aşamalarda kullanarak kaynak tasarrufu sağlanır.
// ASMD Algorithmic state mach,ne + data diyagramı
// fsm diyagramına benzer fakat datapath işlemlerinin her adımda ne olacağını da gösterir.
// her state kutusunun içinde bu clock çevriminde hangi register transferi gerçekleşiyor gibi bilgiler yazar

// fsmd örneği  basit toplama döngüsü accumulator 
// senaryomuz giriş olarak gelen n adet değeri toplayıp sonuç registerına kaydetmek istediğimizi varsayalım fsm her clock çevriminde bir değeri toplayıp sayaç değeri sıfır olunca bitiş durumuna geçecek olsun.

// verilog kod yapııs 
// data path:
// acc_Reg (toplamı saklayan register)
//cnt_Reg (kalan eleman sayıcını tutan register)
// din her clockta gelen veri
//add_acc işlemi acc_Reg <= acc_reg + din
//fsm control path
// durumlar IDLE ACCUM DONE
//aCCUM durumunda her clock kenarında bir keleme yapar sayaç sıfıra inince done durumuna geçeer

module accumulator_fsmd(
    input wire  clk,
    input wire  reset,
    input wire [7:0] din, // gelen veri
    input wire [7:0] num_samples, // toplanacak değer adedi
    input wire    start,
    output reg [15:0] sum_out, // sonuç
    output reg    done

);

    // data path için registerlar
    reg [15:0] acc_reg;
    reg [7:0]  cnt_reg;

    // FSM durumları
    localparam IDLE = 2'b00,
               ACCUM = 2'b01,
               DONE  = 2'b10;
    reg [1:0] current_state, next_state;

    // ================1) state register ===========
    always @(posedge clk or posedge reset) begin 
        if (reset) begin
            current_state <= IDLE;
            end else begin
                current_state <= next_state;
            end
        end

        // ==============2) data path register =========
        always @