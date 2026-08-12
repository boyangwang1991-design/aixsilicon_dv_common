//======================================================================
// AIX DV Common - RAL 基础扩展
// File    : src/ral/dv_ral_pkg.sv
// Purpose : reg block/map/field 公共扩展与 reset 值校验辅助。
//           SystemRDL 是事实源（归所属 IP），PeakRDL 生成 UVM RAL 模型，
//           本包提供 RAL 基类扩展与公共工具。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_ral_pkg;

  import uvm_pkg::*;
  import dv_common_types_pkg::*;
  import dv_status_pkg::*;

  //--------------------------------------------------------------------------
  // RAL 操作类型
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_RAL_OP_READ  = 0,
    DV_RAL_OP_WRITE = 1,
    DV_RAL_OP_RMW   = 2
  } dv_ral_op_e;

  //--------------------------------------------------------------------------
  // 公共 reg block 扩展：提供 reset 值校验与排除策略挂载
  //--------------------------------------------------------------------------
  class dv_ral_reg_block_ext extends uvm_reg_block;

    // 排除策略占位（正式实现读取 metadata/csr_exclusions.yaml）
    protected string m_csr_exclusions[$];

    function new(string name = "dv_ral_reg_block_ext");
      super.new(name);
    endfunction

    // 添加排除模式，例如 "*.status.live_*"
    function void add_csr_exclusion(string pattern);
      m_csr_exclusions.push_back(pattern);
    endfunction

    // 校验某寄存器是否被排除（通配匹配）
    function bit is_excluded(string reg_name, string test_name);
      foreach (m_csr_exclusions[i]) begin
        if (uvm_re_match(m_csr_exclusions[i], reg_name))
          return 1;
      end
      return 0;
    endfunction

    // 对比 reset 值（get_reset 与期望值），供 HW reset sequence 使用
    function bit check_hw_reset_value(uvm_reg rg, string test_name,
                                      dv_status_service status_svc = null);
      uvm_reg_field fs[$];
      uvm_reg_field field;
      logic [63:0] hw_val, exp_val;
      bit ok = 1;
      rg.get_fields(fs);
      foreach (fs[i]) begin
        field = fs[i];
        hw_val = field.get_reset();
        exp_val = field.get(); // frontdoor 读取后缓存
        if (hw_val !== exp_val) begin
          ok = 0;
          `uvm_error("DV_RAL_RESET",
            $sformatf("reg=%s field=%s hw_reset=%h mismatch=%h",
                      rg.get_name(), field.get_name(), hw_val, exp_val))
        end
      end
      return ok;
    endfunction

  endclass

  //--------------------------------------------------------------------------
  // 公共 reg 扩展
  //--------------------------------------------------------------------------
  class dv_reg_ext extends uvm_reg;

    function new(string name = "dv_reg_ext", int unsigned n_bits = 32,
                 int has_coverage = UVM_NO_COVERAGE);
      super.new(name, n_bits, has_coverage);
    endfunction

  endclass

  //--------------------------------------------------------------------------
  // 公共 field 扩展
  //--------------------------------------------------------------------------
  class dv_reg_field_ext extends uvm_reg_field;

    function new(string name = "dv_reg_field_ext");
      super.new(name);
    endfunction

  endclass

endpackage : dv_ral_pkg
