use rouille::Request;
use rouille::Response;

use std::collections::HashMap;

#[derive(PartialEq, Debug)]
pub enum State {
    Init, Setup, Live,
}

#[derive(PartialEq, Debug)]
pub enum Signal {
    EnterSetup, EnterLive, Reset,
}

use Signal::*;
use State::*;

/// Handles requests for authentication
pub struct AuthHandler {
    pub state: State,
    // pub table: Vec<(String, String)>, // A list of valid user, password pairs
    pub table: HashMap<String, String>, // A list of valid user, password pairs
}

impl AuthHandler {

    pub fn new() -> Self {
        Self { state: Init, table: HashMap::new(), }
    }

    /// Add a new user password pair to the table, should only be possible in
    /// Setup mode.
    pub fn register(&mut self, user: &str, pass: &str) -> Result<(), String>{

        if self.state != State::Setup { return Err("not in the setup state".to_string()) }

        self.table.insert(user.to_string(), pass.to_string());
        Ok(())
    }

    /// Check if a user password pair is in the table, should only be possible
    /// in Live mode
    pub fn authenticate(&self, user: &str, pass: &str) -> Result<bool, String> {
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

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn register() {
        let mut server = AuthHandler::new();

        assert!(server.register("", "").is_err());
        server.update_state(EnterSetup);
        assert!(server.register("", "").is_ok());
        server.update_state(EnterLive);
        assert!(server.register("", "").is_err());

    }

    #[test]
    fn state_transitions() {
        let mut server = AuthHandler::new();

        assert_eq!(server.state, Init);
        server.update_state(EnterSetup);
        assert_eq!(server.state, Setup);
        server.update_state(EnterLive);
        assert_eq!(server.state, Live);
    }
}


use std::io::Read;

mod routes {
    use super::*;
    pub fn auth_rtmp(request: &Request) -> Response { todo!(); }
    pub fn auth_icecast(request: &Request) -> Response { todo!(); }
    pub fn auth_register(request: &Request) -> Response { todo!(); }
}

/// Assigns incoming HTTP requests to a route function based on their method
/// and URL
pub fn router(request: &Request) -> Response {
    match (request.method(), request.url().as_str()) {
        ("POST", "/auth_rtmp") => routes::auth_rtmp(request),
        ("POST", "/auth_icecast") => routes::auth_rtmp(request),
        ("POST", "/register") => routes::auth_rtmp(request),

        // default case
        _ => Response::empty_404(),
    }
    // let mut buf = Vec::<u8>::new();
    // request.data().expect("failed").read_to_end(&mut buf).unwrap();

    // println!("{:#?}", request);
    // println!("{:#?}", String::from_utf8_lossy(&buf));

    // Response::text("test") 
}

fn main() {
    println!("Hello, world!");
    rouille::start_server("0.0.0.0:4000", |request| {
        router(request)
    });
}
