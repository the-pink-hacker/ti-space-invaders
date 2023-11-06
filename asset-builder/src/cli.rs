use std::path::PathBuf;

use clap::Parser;

#[derive(Debug, Parser)]
pub struct SpriteArgs {
    pub sprite_path: PathBuf,
    pub out_path: PathBuf,
}

#[derive(Debug, Parser)]
pub struct TextArgs {
    pub text_source: PathBuf,
    pub out_path: PathBuf,
}

#[derive(Debug, clap::Subcommand)]
pub enum Subcommand {
    Sprites(SpriteArgs),
    Text(TextArgs),
}

#[derive(Debug, Parser)]
pub struct Args {
    #[command(subcommand)]
    pub subcommand: Subcommand,
}
