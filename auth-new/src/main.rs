use tide;
use std::collections::HashMap;
use tide::Response;

use std::sync::{Arc, Mutex};

#[derive(Clone, PartialEq, Debug)]
pub enum State {
    Init, Setup, Live,
}

#[derive(Clone, PartialEq, Debug)]
pub enum Signal {
    EnterSetup, EnterLive, Reset,
}

impl Signal {
    pub fn from_str(input: &str) -> Result<Self, String> {
        match input.to_uppercase().as_str() {
            "SETUP" | "ENTERSETUP" => Ok(Self::EnterSetup),
            "LIVE" | "ENTERLIVE" => Ok(Self::EnterLive),
            "RESET" => Ok(Self::Reset),
            _ => Err(format!("Could not parse: {}", input)),
        }
    }
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
        let mut state = request.state().lock().unwrap();

        state.update_state(Signal::EnterSetup);
        let table = format!("{:?}", state);

        let response = Response::builder(200)
            .body(table)
            .build();

        Ok(response)
    }

    pub async fn send_signal(request: Request) -> tide::Result {

        let signal_str = request.param("signal")?;
        let signal = Signal::from_str(&signal_str).unwrap();

        let mut server = request.state().lock().unwrap();
        let result = server.update_state(signal);

        let response = Response::builder(200)
            .body(format!("{:?}", server.state))
            .build();

        Ok(response)
    }

    use tide::prelude::*;

    /// Expected input to the `register` http route. This should be attached as JSON in the request
    /// body
    #[derive(Deserialize, Debug)]
    struct RegisterInput {
        username: String,
        password: String,
    }

    pub async fn register(mut request: Request) -> tide::Result {

        let input: RegisterInput = request.body_json().await.unwrap();
        let mut server = request.state().lock().unwrap();
        let result = server.register(&input.username, &input.password);

        if let Err(e) = result {
            return Ok(Response::builder(400).body("not allowed").build());
        }

        Ok(Response::builder(200).build())
    }

    pub async fn auth(mut request: Request) -> tide::Result {
        let input: RegisterInput = request.body_json().await.unwrap();
        let server = request.state().lock().unwrap();

        let result = server.authenticate(&input.username, &input.password).unwrap_or(false);

        let output = match result {
            true  => Response::builder(200).build(),
            false => Response::builder(418).build(),
        };

        Ok(output)
    }
}


async fn router(mut request: Request) -> tide::Result {
    Ok(Response::builder(200).build())
}

type ServerState = Arc<Mutex<AuthServer>>;
type Request = tide::Request<ServerState>;

#[async_std::main]
async fn main() {
    let mut auth_server = AuthServer::new();
    let server_state = Arc::new(Mutex::new(auth_server));
    let mut http = tide::with_state(server_state);

    // define http routes
    http.at("/auth/rtmp").get(router);

    http.at("/auth").post(routes::auth);
    http.at("/ctl/*signal").post(routes::send_signal);
    http.at("/register").post(routes::register);
    http.at("/debug").get(routes::debug);

    let result = http.listen("0.0.0.0:4000").await;

    if let Err(e) = result {
        println!("Server terminated with error: {}", e);
    }

}
