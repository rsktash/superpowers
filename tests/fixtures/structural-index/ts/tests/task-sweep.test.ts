export async function cadenceOne(): Promise<number> {
  const { suggestCadence } = await import("../src/task-sweep.js");
  return suggestCadence(1);
}

export async function cadenceTwo(): Promise<number> {
  const { suggestCadence } = await import("../src/task-sweep.js");
  return suggestCadence(2);
}

export async function cadenceThree(): Promise<number> {
  const { suggestCadence } = await import("../src/task-sweep.js");
  return suggestCadence(3);
}

export async function cadenceFour(): Promise<number> {
  const { suggestCadence } = await import("../src/task-sweep.js");
  return suggestCadence(4);
}

export async function cadenceFive(): Promise<number> {
  const { suggestCadence } = await import("../src/task-sweep.js");
  return suggestCadence(5);
}

export async function cadenceSix(): Promise<number> {
  const { suggestCadence } = await import("../src/task-sweep.js");
  return suggestCadence(6);
}

export async function cadenceSeven(): Promise<number> {
  const { suggestCadence } = await import("../src/task-sweep.js");
  return suggestCadence(7);
}

export async function sweepCase(): Promise<void> {
  const { startTaskSweep } = await import("../src/task-sweep.js");
  startTaskSweep();
}
