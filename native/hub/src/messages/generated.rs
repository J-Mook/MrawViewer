#![allow(unused_imports)]
#![allow(unused_mut)]

use prost::Message;
use rinf::DartSignal;
use std::cell::RefCell;
use std::collections::HashMap;
use std::sync::Mutex;
use std::sync::OnceLock;

type SignalHandlers =
    OnceLock<Mutex<HashMap<i32, Box<dyn Fn(Vec<u8>, Option<Vec<u8>>) + Send>>>>;
static SIGNAL_HANDLERS: SignalHandlers = OnceLock::new();

pub fn handle_dart_signal(
    message_id: i32,
    message_bytes: Vec<u8>,
    blob: Option<Vec<u8>>
) {    
    let mutex = SIGNAL_HANDLERS.get_or_init(|| {
        let mut hash_map =
            HashMap
            ::<i32, Box<dyn Fn(Vec<u8>, Option<Vec<u8>>) + Send + 'static>>
            ::new();
hash_map.insert(
    0,
    Box::new(|message_bytes: Vec<u8>, blob: Option<Vec<u8>>| {
        use super::mooksviewer::*;
        let message = InputMessage::decode(
            message_bytes.as_slice()
        ).unwrap();
        let dart_signal = DartSignal {
            message,
            blob,
        };
        let cell = INPUT_MESSAGE_SENDER
            .get_or_init(|| Mutex::new(RefCell::new(None)))
            .lock()
            .unwrap();
        let sender = cell.clone().replace(None).expect(concat!(
            "Looks like the channel is not created yet.",
            "\nTry using `InputMessage::get_dart_signal_receiver()`."
        ));
        let _ = sender.try_send(dart_signal);
    }),
);
hash_map.insert(
    1,
    Box::new(|message_bytes: Vec<u8>, blob: Option<Vec<u8>>| {
        use super::mooksviewer::*;
        let message = MessageOpenFile::decode(
            message_bytes.as_slice()
        ).unwrap();
        let dart_signal = DartSignal {
            message,
            blob,
        };
        let cell = MESSAGE_OPEN_FILE_SENDER
            .get_or_init(|| Mutex::new(RefCell::new(None)))
            .lock()
            .unwrap();
        let sender = cell.clone().replace(None).expect(concat!(
            "Looks like the channel is not created yet.",
            "\nTry using `MessageOpenFile::get_dart_signal_receiver()`."
        ));
        let _ = sender.try_send(dart_signal);
    }),
);
hash_map.insert(
    2,
    Box::new(|message_bytes: Vec<u8>, blob: Option<Vec<u8>>| {
        use super::mooksviewer::*;
        let message = MessagePlayControl::decode(
            message_bytes.as_slice()
        ).unwrap();
        let dart_signal = DartSignal {
            message,
            blob,
        };
        let cell = MESSAGE_PLAY_CONTROL_SENDER
            .get_or_init(|| Mutex::new(RefCell::new(None)))
            .lock()
            .unwrap();
        let sender = cell.clone().replace(None).expect(concat!(
            "Looks like the channel is not created yet.",
            "\nTry using `MessagePlayControl::get_dart_signal_receiver()`."
        ));
        let _ = sender.try_send(dart_signal);
    }),
);
        Mutex::new(hash_map)
    });

    let guard = mutex.lock().unwrap();
    let signal_handler = guard.get(&message_id).unwrap();
    signal_handler(message_bytes, blob);
}
