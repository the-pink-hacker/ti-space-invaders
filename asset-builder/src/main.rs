mod cli;
mod sprite;
mod text;

use clap::Parser;
use cli::{Args, Subcommand};
use serde::Deserialize;
use sprite::{generate_sprite, load_sprite_metadata};
use text::generate_text;

#[derive(Debug, Deserialize)]
pub struct PointerTable {
    name: String,
    offset: Option<u8>,
}

fn main() -> anyhow::Result<()> {
    let args = Args::parse();

    match args.subcommand {
        Subcommand::Sprites(sprite_args) => {
            let metadata = load_sprite_metadata(&sprite_args.sprite_path)?;

            for (sprite_name, metadata) in metadata.iter() {
                generate_sprite(
                    &sprite_args.sprite_path,
                    &sprite_args.out_path,
                    sprite_name,
                    metadata,
                )?;
            }

            Ok(())
        }
        Subcommand::Text(text_args) => generate_text(text_args),
    }
}
