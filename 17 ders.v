// kripto hızlandırıcı AES SHA RTL  tasarım örneği
//AES ADVANCED ENCRYPTİON STANDARD SHA SECURE HASH ALGORİTHM
// AES - 128 RTL FSMD YAKLAŞIMI

//aes genel bakış
// blok şifreleeme standardı
// 128 bit blok 128 192 256 bit anahtar key seçenekleri
// burada aes 128 128 bit key 10 tur round en yaygın
// aes 128 şifreleme akışı
// 128 bit plaintext 128 bit key
// round aşamaları 10 roun
// subbytes s box dönüşümü
// shifrows
// mixcolumns
// addroundkey
// 10 turdan sonra 128 bit cphertext çıkışı
// 128 bit key // fsmd tasarım yaklaşımı
// data path
// 128 bit state register plainrext ciphertext
// round key registerlar veya key schedule bloğu
// subbytes için lut  s box shift wors babir permütasyon mixcolumns matris çarpımı 
// control path fsm
// durumler IDLE KEY_EXP ROUND_X DONE
// HER CLOCKTA BİR ALT AŞAMAYI GERÇEKLEŞTİRME VE PİPELİNE TASARIM HER TUTURU BİR İKİ CLOCKTA BİTİRME
// TAM PİPELİNELİ HER ROUND BİR AŞAMA 10 CLOCKTA ŞİFRELEME BİTER LUT VE KAYNAK TÜKETİMİ ARTAR THROUGHPUT YÜKSEK
// SIRALI İTERATİVE ttek round mantığını tekrar tekrar kullan 10 tur için 10 clokc herekir 

// aes 128 sıralı fsmd
// aes implemantasyonu değildir özellikle s box tablo mixcolumns key expansion ayrıntıları

module aes128_enc (
    input wire      clk,
    input wire      reset,
    input wire      start,
    input wire [127:0] plaintext,
    input wire [127:0] key,
    output reg [127:0] ciphertext,
    output reg       done
);

    // ınternal registers
    reg [127:0] state_reg ;
    reg [127:0] round_key_reg ;
    reg [3:0]   round_count;

    // FSM states
    localparam IDLE = 3'd0,
               LOAD = 3'd1,
               KEYEX = 3'd2,
               ROUND = 3'd3,
               FINAL = 3'd4,
               DONE_ST= 3'd5;
    reg [2:0] current_state, next_state;

    // example subbytes function placeholder
    function [127:0] sub_bytes;
        input [127:0] in_block
        integer i;
        reg [127:0] out_block;
    begin
      //16 byte her byte s boxtan geçecek
      // burada kısaltılmış şekilde
      out_block = in_block; // a real design uses sbox lookups
      sub_bytes = out_block;
    end
    endfunction

    // example shiftrows
    function [127:0] shift_rows;
        input [127:0] in_block;
        // ..... real shift logic ...
    begin
        shift_rows = in_block;
    end
    endfunction

    // example mixxcolumns
    function [127:0] mix_columns;
        input [127:0] in_block;
        // ... matrix multiplication ..
    begin
        mix_columns = in_block;
    end
    endfunction

    // key expansion partial example
    // real design has rcon usage rotworcd subword etc
    function [127:0] key_schedule;
        input [127:0] prev_key;
        input [3:0] round_no;
    begin
        // for simplicity
        key_schedule = prev_key; // placeholder
    end
    endfunction

    //......................................
    // state register 
    //.....................
    always @(posedge clk or posedge reset) begin
        if ( reset) begin
            current_state <= IDLE;
        end else begin
            current_State <= next_state;
        end
    end

    // data path

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= 128'd0;
            round_key_reg <= 128'd0;
            ciphertext   <= 128'd0;
            round_count <=4'd0;
        end else begin
            // load plaintext & key
            state_Reg <= plaintext;
            round_key_reg <= key;
            round_count <= 4'd0;
        end

        KEYEX: begin
            // get next round key
            round_key_reg <= key_schedule(round_key_reg, round_count)
        end

        ROUND: begin
            // round steps
            // 1 subbytes
            state_reg <= sub_bytes(state_reg);
            // SHİFTROWS
            state_reg <= shift_rows(state_reg);
            // mixcolums skip if final round
            if ( round_count < 4'd9) begin
                state_reg <= mix_columns(state_reg);
            end
            // addroundkey
            state_reg <= state_reg ^round_key_reg;

            round_count <= round_Count + 1'b1;
        end

        FINAL: begin
            ciphertext <= state_reg;
        end
        default: ;
      endcase
    end
end

// next state output logic

always @(*) begin
    next_state = current_state;
    done       = 1'b0;

    case(current_state)
        IDLE: begin
            if ( start)
                 next_state = LOAD;
        end

        LOAD: begin
            next_state = KEYEX;
        end

        KEYEX: begin
            next_state = ROUND;
        end

        ROUND: begin
            // after each round check if round_count ==10
            if (round_count == 4'd10) begin
                next_state = FINAL;
            end else begin
                next_state = KEYEX; // EXPAND KEY FOR NEXT ROUND
            end
        end

        FINAL:begin
            done = 1'b1;
            next_state = DONE=ST;
        end

        DONE_ST: begin
            // wait for next start
        if (!start)
            next_state =IDLE;
        end

        default: next_state = IDLE;
    endcase
end

endmodule








