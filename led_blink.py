import argparse
import time
jjjjjjjjjjjjjjdd

def blink_simulation(interval: float) -> None:
    """Simula un LED encendiendo y apagando en consola."""
    state = False
    print("Iniciando simulacion de LED. Presiona Ctrl+C para salir.")
    while True:
        state = not state
        print("LED ON" if state else "LED OFF")
        time.sleep(interval)


def blink_raspberry(pin: int, interval: float) -> None:
    """Controla un LED real en Raspberry Pi usando gpiozero."""
    try:
        from gpiozero import LED
    except ImportError as exc:
        raise SystemExit(
            "No se encontro 'gpiozero'. Instala con: pip install gpiozero"
        ) from exc

    led = LED(pin)
    print(f"Iniciando LED en GPIO {pin}. Presiona Ctrl+C para salir.")

    try:
        while True:
            led.on()
            print("LED ON")
            time.sleep(interval)

            led.off()
            print("LED OFF")
            time.sleep(interval)
    finally:
        led.off()


def main() -> None:
    parser = argparse.ArgumentParser(description="Parpadeo de LED en Python")
    parser.add_argument(
        "--modo",
        choices=["sim", "rpi"],
        default="sim",
        help="sim: consola, rpi: LED real en Raspberry Pi",
    )
    parser.add_argument(
        "--intervalo",
        type=float,
        default=1.0,
        help="Segundos entre encendido y apagado",
    )
    parser.add_argument(
        "--pin",
        type=int,
        default=17,
        help="Pin GPIO para modo rpi (por defecto 17)",
    )
    args = parser.parse_args()

    if args.intervalo <= 0:
        raise SystemExit("El intervalo debe ser mayor que 0")

    if args.modo == "sim":
        blink_simulation(args.intervalo)
    else:
        blink_raspberry(args.pin, args.intervalo)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nPrograma detenido por el usuario.")
