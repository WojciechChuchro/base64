# base64

A small [Zig](https://ziglang.org/) project that implements Base64 encoding and decoding. It demonstrates encoding a string to Base64 and decoding it back.

## Requirements

- **Zig 0.14.0** or later ([download](https://ziglang.org/download/))

## Building

From the project root:

```bash
zig build
```

This produces an executable at `zig-out/bin/main`.

## Running

**Run without installing:**

```bash
zig build run
```

**Run the installed binary:**

```bash
zig build
./zig-out/bin/main
```

## Docker

### Build the image

```bash
docker build -t base64 .
```

### Run the container

```bash
docker run --rm base64
```

### Using Docker Compose (optional)

If you use Docker Compose:

```bash
docker compose run --rm app
```

## License

This project is for educational purposes.
