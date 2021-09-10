use tide;
use std::collections::HashMap;
use tide::Response;

#[derive(Clone, PartialEq, Debug)]
pub enum State {
    Init, Setup, Live,
}

#[derive(Clone, PartialEq, Debug)]
pub enum Signal {
    EnterSetup, EnterLive, Reset,
}

use Signal::*;
use State::*;

/// Handles requests for authentication
#[derive(Clone, Debug)]
pub struct AuthServer {
    pub state: State,
    pub table: HashMap<String, String>, // A list of valid user, password pairs
}

impl AuthServer {

    pub fn new() -> Self {
        Self { state: Init, table: HashMap::new(), }
    }

    /// Add a new user password pair to the table, should only be possible in
    /// Setup mode.
    pub fn register(&mut self, user: &str, pass: &str) -> Result<(), String> {

        if self.state != State::Setup { return Err("not in the setup state".to_string()) }

        self.table.insert(user.to_string(), pass.to_string());
        Ok(())
    }

    /// Check if a user password pair is in the table, should only be possible
    /// in Live mode
    pub fn authenticate(&self, user: &str, pass: &str) -> Result<bool, String> {

        if self.state != State::Live { return Err("not in the live state".to_string()) }

        let res = self.table.get(user).and_then(|user| Some(user.as_str())) == Some(pass);
        Ok(res)
    }

    /// Handle state transitions
    pub fn update_state(&mut self, signal: Signal) -> Result<(), String> {
        match (&self.state, signal) {
            (_, Reset) => self.state = Init,
            (Init, EnterSetup) => self.state = Setup,
            (Setup, EnterLive) => self.state = Live,
            _ => return Err("Not a valid state transition".to_string()),
        };

        Ok(())
    }
}

// TODO: pretty print the state of the Auth Server
// impl std::fmt::Display for AuthServer {
//     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
//         write!("{}", )
//     }
// }

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn register() {
        let mut server = AuthServer::new();

        assert!(server.register("", "").is_err());
        server.update_state(EnterSetup);
        assert!(server.register("", "").is_ok());
        server.update_state(EnterLive);
        assert!(server.register("", "").is_err());

    }

    #[test]
    fn state_transitions() {
        let mut server = AuthServer::new();

        assert_eq!(server.state, Init);
        server.update_state(EnterSetup);
        assert_eq!(server.state, Setup);
        server.update_state(EnterLive);
        assert_eq!(server.state, Live);
    }

    #[test]
    fn auth() {
        let mut server = AuthServer::new();

        server.update_state(EnterSetup);
        server.register("testuser", "testpass");
        server.register("testuser", "testpass");

        server.update_state(EnterLive);
        assert!(server.authenticate("testuser", "testpass").unwrap());
        assert!(!server.authenticate("testuser", "notpass").unwrap());
    }
}

mod routes {

    use super::*;

    pub async fn debug(request: Request) -> tide::Result {
        let state = request.state();
        let table = format!("{:?}", state);

        let response = Response::builder(200)
            .body(table)
            .build();

        Ok(response)
    }

    pub async fn send_signal(request: Request) -> tide::Result {

        let signal_str = request.param("signal")?;
        let signal = match signal_str.to_uppercase().as_str() {
            "SETUP" => Signal::EnterSetup,
            "LIVE"  => Signal::EnterLive,
            "RESET" => Signal::Reset,
            _ => todo!(),
        };

        let server = request.state();
        let result = server.update_state(signal);

        todo!();
    }
}


async fn router(mut request: Request) -> tide::Result {
    Ok(Response::builder(200).build())
}

type Request = tide::Request<AuthServer>;

#[async_std::main]
async fn main() {
    let mut auth_server = AuthServer::new();
    let mut http = tide::with_state(auth_server);

    // define http routes
    http.at("/auth/rtmp").get(router);

    http.at("/ctl/*signal").post(routes::send_signal);
    http.at("/debug").get(routes::debug);

    let result = http.listen("0.0.0.0:4000").await;

    if let Err(e) = result {
        println!("Server terminated with error: {}", e);
    }

}
