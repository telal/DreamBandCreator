const accord_Am = "Am";
const accord_Dm = "Dm";

const _open = [
  const AccordItem(1, 0, 64),
  const AccordItem(2, 0, 59),
  const AccordItem(3, 0, 55),
  const AccordItem(4, 0, 50),
  const AccordItem(5, 0, 45),
  const AccordItem(6, 0, 40)
];

const am = [
  const AccordItem(1, 0, 64),
  const AccordItem(2, 2, 51),
  const AccordItem(3, 3, 58),
  const AccordItem(4, 3, 53),
  const AccordItem(5, 0, 45),
  const AccordItem(6, 0, 40)
];

const _dm = [
  const AccordItem(1, 1, 65),
  const AccordItem(2, 2, 62),
  const AccordItem(3, 3, 57),
  const AccordItem(4, 0, 50),
  const AccordItem(5, 0, 45),
  const AccordItem(6, 0, 40)
];

const accords = {
  accord_Am: am,
  accord_Dm: _dm
};

class AccordItem {

  final int string;
  final int fret;
  final int code;

  const AccordItem(this.string, this.fret, this.code);
}
