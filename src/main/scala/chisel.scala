import chisel3._
import chisel3.util._
import chisel3.simulator.EphemeralSimulator._

class top(b0: Int, b1: Int, b2: Int, b3: Int) extends Module {
  val io = FlatIO(new Bundle {
    val in = Input(UInt(8.W))
    val out = Output(UInt(8.W))
  })

  val x_n1 = RegNext(io.in, 0.U)
  val x_n2 = RegNext(x_n1, 0.U)
  val x_n3 = RegNext(x_n2, 0.U)

  io.out := b0.U*io.in + b1.U*x_n1 + b2.U*x_n2 + b3.U*x_n3
  
}

object VerilogMain extends App {
  emitVerilog(new top(), Array("--target-dir", "build/gen_vsrc"))
}

object TestMain extends App {
  simulate(new LFSR()) { c =>
    c.reset.poke(true.B)
    c.clock.step(1)
    c.reset.poke(false.B)
    c.io.out.expect(0x01.U)
    c.clock.step(1)
    println(s"out = ${c.io.out.peek().litValue}")
  }


