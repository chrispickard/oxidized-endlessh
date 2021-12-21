use std::fs::File;
use std::io::BufReader;
use std::net::SocketAddr;
use std::time::Duration;

use bytebuffer::ByteBuffer;
use rand::{thread_rng, Rng};
use serde::Deserialize;
use structopt::StructOpt;
use tokio::io::AsyncWriteExt;
use tokio::net::TcpListener;
use tokio::time;

/// Example for allowing to specify options via environment variables.
#[derive(StructOpt, Debug)]
struct Opt {
    #[structopt(
        short("-f"),
        long,
        env = "OXIDIZED_ENDLESSH_CONFIG",
        default_value = "/etc/oxidized-endlessh/config.json"
    )]
    config_file: String,
}

#[derive(Deserialize)]
struct Config {
    addrs: Vec<SocketAddr>,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let opt = Opt::from_args();
    let file = match File::open(opt.config_file) {
        Ok(file) => file,
        Err(e) => {
            eprintln!("failed to open file; err = {:?}", e);
            eprintln!(
                r#"places oxidized_endlessh will look in descending precedence:
-f/--config-file
OXIDIZED_ENDLESSH_CONFIG
/etc/oxidized-endlessh/config.json"#
            );
            panic!("{}", e)
        }
    };
    let buf_reader = BufReader::new(file);
    let conf: Config = serde_json::from_reader(buf_reader)?;
    let mut runtime = tokio::runtime::Runtime::new().unwrap();
    let listener = TcpListener::bind("127.0.0.1:8000").await?;

    loop {
        let (mut socket, _) = listener.accept().await?;
        let mut b = ByteBuffer::new();
        tokio::spawn(async move {
            // In a loop, read data from the socket and write the data back.
            loop {
                time::sleep(Duration::from_secs(10)).await;
                b.clear();
                let r: u64 = thread_rng().gen();
                let response = format!("{:x}\r\n", r);

                b.write_bytes(response.as_bytes());
                // Write the data back
                if let Err(e) = socket.write_all(&b.to_bytes()).await {
                    eprintln!("failed to write to socket; err = {:?}", e);
                    return;
                }
            }
        });
    }
}
