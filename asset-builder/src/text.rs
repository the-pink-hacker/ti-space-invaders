use std::{
    fs::{self, File},
    io::Write,
};

use crate::cli::TextArgs;
use anyhow::bail;
use linked_hash_map::LinkedHashMap;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
struct TextSource {
    text: String,
}

pub fn generate_text(text_args: TextArgs) -> anyhow::Result<()> {
    let source_file = fs::read_to_string(text_args.text_source)?;

    let parsed_source = toml::from_str::<LinkedHashMap<String, TextSource>>(&source_file)?;

    let mut output = String::new();

    for (name, source) in parsed_source.iter() {
        output += &format!("Text{}:", name);

        let mut characters = Vec::with_capacity(source.text.len());

        for character in source.text.chars() {
            let converted_character = match character {
                '0'..='9' => character as u8 & 0b00001111, // '0' => 0
                'A'..='Z' => character as u8 - 'A' as u8 + 10,
                'a'..='z' => character as u8 - 'a' as u8 + 10,
                ' ' => 36,
                _ => bail!("character '{}', not supported", character),
            };

            characters.push(converted_character.to_string());
        }

        output += &format!("\n.db {}\n.db $FF\n", characters.join(","));
    }

    let mut output_file = File::create(text_args.out_path)?;
    output_file.write_all(output.as_bytes())?;

    Ok(())
}
