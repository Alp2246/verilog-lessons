// senaryo zynq ps tarafında çalışan bir uygulama pl tarafında toplama işlemini donanımda hızlandırmak istiyor. plde axı-LİTE registerlar üzerinden iki sayıyı ayarlıyoruz donanım bunları toplayıc sonucu başka bir registera yazıyor

// donanım tarafı verilog
// axı lite registerlarına basit bir slv_Reg0 ilk sayı slv_Reg1 ikinci sayı slv_Reg2 sonuç tanımlamış bir taslağı gösterir 

module adder_accel_axi_lite #(
    parameter C_S_AXI_aDDR_WIDTH = 4,
    parameter C_S_AXI_DATA_WIDTH = 32
)(

    // AXI LİTE INTERFACE
    input wire                  s_axi_aclk,
    input wire                  s_axi_aresetn,
    input wire [C_S_AXI_ADDR_WIDTH-1:0]                  s_axi_awaddr,
    input wire                  s_axi_awvalid,
    output wire                 s_axi_awready,
    input wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
    input wire [3:0]            s_axi_wstrb,
    input wire                  s_axi_wvalid,
    output wire                 s_axi_wready,
    output wire [1:0]           s_axi_bresp,
    output wire                 s_axi_bvalid,
    input wire                  s_axi_bready,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input wire                  s_axi_arvalid,
    output wire                 s_axi_arready,
    output wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
    output wire [1:0]           s_axi_rresp,
    output wire                 s_axi_rvalid,
    input wire                  s_axi_arready

)

//-------------------------------------------------------------------------
    // Internal registers (slv_reg0, slv_reg1 => giriş veriler; slv_reg2 => sonuç)
    //-------------------------------------------------------------------------

        reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg0;
        reg [C_S_AXI_ADDR_WIDTH-1:0] slv_reg1;
        reg [C_S_AXI_ADDR_WIDTH-1:0] slv_reg2;

        // axı lite signal states
        // normalde protokolün tam implemantationu epey uzun
        // burada yalnızca kavramsal bir iskelet gösteriyoruz

        // ready sinyalleri
        assign s_axi_awready = 1'b1; // basit yaklaşım her zaman hazır
        assign s_Axi_wready = 1'b1;
        assign s_axi_arredy = 1'b1;

        // write response
        assign s_axi_bresp = 2'b00; // okay
        assign s_axi_bvalid = s_Axi_Wvalid & s_Axi_awvalid; // bu da basit kurgulandı

        // read response
        assign s_axi_rresp = 2'b00; //okay

        // okunacak veri
        reg [C_S_AXI_ADDR_WIDTH-1:0] reg_data_out;
        assign s_axi_rdata = reg_data_out;

        //read valid
        assign s_axi_rvalid = s_axi_arvalid;

    //-------------------------------------------------------------------------
    // Register Write Logic (Basitleştirilmiş)
    //-------------------------------------------------------------------------

    always @(posedge s_axi_aclk) begin
      if (!s_axi_aresetn) begin
        slv_reg0 <= 32'd0;
        slv_reg1 <= 32'd0;
        slv_reg2 <= 32'd0;
      end else begin
        // yazma sırasında hangi adres yazılıyorsa ilgili registerı güncelle
        if (s_axi_awvalid & s_axi_wvalid) begin
            case (s_axi_awaddr)
                4'h0: slv_reg0 <= s_axi_wdata;
                4'h4: slv_reg1 <= s_axi_wdata;
                default: ; // yok say
            endcase
        end

// her clockta sonuç registerını güncelle donanım hızlandırıcı mantığı 
        slv_reg2 <= slv_reg0 + slv_reg1;    
      end
    end
  //-------------------------------------------------------------------------
    // Register Read Logic (Basitleştirilmiş)
    //-------------------------------------------------------------------------

    always@(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            reg_data_out <= 32'd0;
        end else begin
            if (s_axi_arvalid) begin
                case (s_axi_araddr)
                e (s_axi_araddr)
                    4'h0: reg_data_out <= slv_reg0;
                    4'h4: reg_data_out <= slv_reg1;
                    4'h8: reg_data_out <= slv_reg2;
                    default: reg_data_out <= 32'hDEAD_BEEF;
                endcase
            end
        end
    end
endmodule

// slv_Reg0 ve slv_reg1 giriş değerlerini tutuyor her clockta toplama yapıp slv_Reg2 ye yazıyoruz
//Axı lite protkolünün hanfshake sinyallerini awready wready arready burada çok basit uttuk gerçek tasraımlarda state machineler kullanarak tma protokol uyumu sağlanır
// cpu bu registerlara mmıo write ypaıp sonucu mmıo read ile okuyabilir

// yazılım tarafı ps basit c kodu 
// zynq ps üzerinde linux userspca registarları bir bellek adresinden erişiyoruz vaviado addres editorda tanan base address 0x43co_0000 gibi

#define ADDER_ACCEL_BASE 0x43C00000
#define REG0_OFFSET      0x00
#define REG1_OFFSET      0x04
#define REG2_OFFSET      0x08

volatile unsigned int *accel_ptr =(unsigned int *)ADDER_ACCEL_BASE;

    int main() {
        unsigned int a = 10;
        unsigned int b= 32;

        // yazma
        accel_ptr[REG0_OFFSET/4] = a;
        accel_ptr[REG1_OFFSET/+] = b;

        // OKUMA
        unsigned int result  = accel_ptr[reg2_offset/+];

        xil_printf("A=%U, result=%u\n", a,b, result);

        return 0;
    }

    // bu bare metal örnek registerlara doğrudan pointer üzerinden erişiyor
    // linux oratamında ise /dev/mem veya özel bir driver yazarak benzer şekilde okuma yazma ypaılabilir

// gerçekte axı handshake ready valid gibi sinyalleri tam protokole uygun şekilde fsm ile yönetmek gerekir 
//Bu örnekle, SoC FPGA (Zynq) üzerinde basit bir donanım hızlandırıcı modülünün Verilog AXI-Lite iskeletini göstermiş olduk.
// cpu tarafında registerlara basit yazma okuma yaparak hızlandırıcının giriş çıkışını kontrol edebiliyirouz


