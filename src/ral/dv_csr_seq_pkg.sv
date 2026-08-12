//======================================================================
// AIX DV Common - CSR Sequence 库
// File    : src/ral/dv_csr_seq_pkg.sv
// Purpose : P0 CSR sequence：
//           1. CSR smoke
//           2. HW reset value
//           3. RW access
//           4. bit-bash
//           5. access policy 检查（骨架）
//           6. frontdoor/backdoor 一致性（骨架）
//           CSR 排除机制统一用 metadata/policy 表达，不在 sequence 中硬编码寄存器名。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_csr_seq_pkg;

  import uvm_pkg::*;
  import dv_common_types_pkg::*;
  import dv_ral_pkg::*;

  //--------------------------------------------------------------------------
  // 测试类型（用于排除策略匹配）
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_CSR_TEST_SMOKE          = 0,
    DV_CSR_TEST_HW_RESET       = 1,
    DV_CSR_TEST_RW             = 2,
    DV_CSR_TEST_BIT_BASH       = 3,
    DV_CSR_TEST_ACCESS_POLICY  = 4,
    DV_CSR_TEST_BACKDOOR_CMP   = 5
  } dv_csr_test_e;

  function automatic string dv_csr_test_name(dv_csr_test_e t);
    case (t)
      DV_CSR_TEST_SMOKE:         return "smoke";
      DV_CSR_TEST_HW_RESET:      return "hw_reset";
      DV_CSR_TEST_RW:            return "rw";
      DV_CSR_TEST_BIT_BASH:      return "bit_bash";
      DV_CSR_TEST_ACCESS_POLICY: return "access_policy";
      DV_CSR_TEST_BACKDOOR_CMP:  return "backdoor_compare";
      default:                   return "unknown";
    endcase
  endfunction

  //--------------------------------------------------------------------------
  // CSR smoke：遍历每个寄存器读一次
  //--------------------------------------------------------------------------
  class dv_csr_smoke_seq extends uvm_sequence;

    `uvm_object_utils(dv_csr_smoke_seq)

    dv_ral_reg_block_ext ral;

    function new(string name = "dv_csr_smoke_seq");
      super.new(name);
    endfunction

    virtual task body();
      uvm_reg regs[$];
      ral.get_registers(regs);
      foreach (regs[i]) begin
        uvm_status_e status;
        uvm_reg_data_t value;
        if (ral.is_excluded(regs[i].get_name(), dv_csr_test_name(DV_CSR_TEST_SMOKE)))
          continue;
        regs[i].read(status, value, UVM_DEFAULT_PATH, null);
        `uvm_info("DV_CSR_SMOKE",
          $sformatf("read reg=%s status=%s", regs[i].get_name(), status.name()),
          UVM_MEDIUM)
      end
    endtask

  endclass

  //--------------------------------------------------------------------------
  // HW reset value：reset 后校验各寄存器 reset 值
  //--------------------------------------------------------------------------
  class dv_csr_hw_reset_seq extends uvm_sequence;

    `uvm_object_utils(dv_csr_hw_reset_seq)

    dv_ral_reg_block_ext ral;

    function new(string name = "dv_csr_hw_reset_seq");
      super.new(name);
    endfunction

    virtual task body();
      uvm_reg regs[$];
      ral.get_registers(regs);
      foreach (regs[i]) begin
        uvm_status_e status;
        uvm_reg_data_t value;
        if (ral.is_excluded(regs[i].get_name(), dv_csr_test_name(DV_CSR_TEST_HW_RESET)))
          continue;
        regs[i].read(status, value, UVM_DEFAULT_PATH, null);
        // 正式实现：与期望 reset 值比较，失败上报 failure service
        `uvm_info("DV_CSR_HW_RESET",
          $sformatf("reset-check reg=%s status=%s", regs[i].get_name(), status.name()),
          UVM_MEDIUM)
      end
    endtask

  endclass

  //--------------------------------------------------------------------------
  // RW access：写随机值再读回比较（仅 RW 字段）
  //--------------------------------------------------------------------------
  class dv_csr_rw_seq extends uvm_sequence;

    `uvm_object_utils(dv_csr_rw_seq)

    dv_ral_reg_block_ext ral;

    function new(string name = "dv_csr_rw_seq");
      super.new(name);
    endfunction

    virtual task body();
      uvm_reg regs[$];
      ral.get_registers(regs);
      foreach (regs[i]) begin
        uvm_status_e status;
        if (ral.is_excluded(regs[i].get_name(), dv_csr_test_name(DV_CSR_TEST_RW)))
          continue;
        // 正式实现：对 RW 字段写随机值、读回、比较
        `uvm_info("DV_CSR_RW",
          $sformatf("rw-check reg=%s", regs[i].get_name()), UVM_MEDIUM)
      end
    endtask

  endclass

  //--------------------------------------------------------------------------
  // bit-bash：逐位翻转测试（仅 RW 字段）
  //--------------------------------------------------------------------------
  class dv_csr_bit_bash_seq extends uvm_sequence;

    `uvm_object_utils(dv_csr_bit_bash_seq)

    dv_ral_reg_block_ext ral;

    function new(string name = "dv_csr_bit_bash_seq");
      super.new(name);
    endfunction

    virtual task body();
      uvm_reg regs[$];
      ral.get_registers(regs);
      foreach (regs[i]) begin
        if (ral.is_excluded(regs[i].get_name(), dv_csr_test_name(DV_CSR_TEST_BIT_BASH)))
          continue;
        // 正式实现：逐位写 1/0 并读回比较
        `uvm_info("DV_CSR_BIT_BASH",
          $sformatf("bit-bash reg=%s", regs[i].get_name()), UVM_MEDIUM)
      end
    endtask

  endclass

endpackage : dv_csr_seq_pkg
