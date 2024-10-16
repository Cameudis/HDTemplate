#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <nvboard.h>
#include "Vtop.h"
#include "verilated.h"
#include "verilated_fst_c.h"

void nvboard_bind_all_pins(Vtop* top);

void single_cycle(Vtop* top) {
  top->clock = 0; top->eval();
  top->clock = 1; top->eval();
}

void reset(Vtop* top, int n) {
  top->reset = 1;
  while (n -- > 0) single_cycle(top);
  top->reset = 0;
}

int main(int argc, char** argv) {

  VerilatedContext* context = new VerilatedContext;
  Vtop* top = new Vtop{context};
  nvboard_bind_all_pins(top);
  nvboard_init();

  Verilated::traceEverOn(true);
  VerilatedFstC* tfp = new VerilatedFstC;
  top->trace(tfp, 99); // Trace 99 levels of hierarchy
  Verilated::mkdir("logs");
  tfp->open("logs/top.fst");

  srand(time(NULL));

  reset(top, 10);

  while (1) {
    nvboard_update();
    single_cycle(top);

    context->timeInc(1);
    tfp->dump(context->time());
    
    if (top->down) {
      break;
    }
  }

  tfp->close();
  nvboard_quit();

  delete tfp;
  delete top;
  delete context;

  return 0;
}
