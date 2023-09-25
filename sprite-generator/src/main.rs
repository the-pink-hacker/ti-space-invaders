use std::{fs, path::PathBuf};

use anyhow::Context;
use clap::Parser;

#[derive(Debug, Parser)]
struct Args {
    #[arg(short, long)]
    sprite_path: PathBuf,
    #[arg(short, long)]
    out_path: PathBuf,
}

fn main() -> anyhow::Result<()> {
    let args = Args::parse();

    let sprite_paths = fs::read_dir(args.sprite_path)?;

    for path in sprite_paths {
        let path = path?.path();
        {
            let is_png = path
                .extension()
                .with_context(|| format!("Failed to get extension of file: {}", path.display()))?
                .to_ascii_lowercase()
                == "";

            if is_png {
                continue;
            };
        }

        let sprite_png = image::io::Reader::open(path.clone())?.decode()?;
        let pixels = sprite_png
            .as_rgb8()
            .with_context(|| format!("Image wasn't 8-bit color: {}", path.display()))?
            .pixels();

        for pixel in pixels {
            println!("{:?}", pixel);
        }
    }

    Ok(())
}
