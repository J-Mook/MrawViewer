#![allow(unused_imports)]

use crate::tokio;
use prost::Message;
use rinf::send_rust_signal;
use rinf::DartSignal;
use rinf::SharedCell;
use std::cell::RefCell;
use std::sync::Mutex;
use std::sync::OnceLock;
use tokio::sync::mpsc::Receiver;
use tokio::sync::mpsc::Sender;

// @generated
/// \[RINF:DART-SIGNAL\]
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct InputMessage {
    #[prost(string, tag="1")]
    pub cmd: ::prost::alloc::string::String,
    #[prost(int32, tag="2")]
    pub int_r_data: i32,
    #[prost(int32, tag="3")]
    pub int_g_data: i32,
    #[prost(int32, tag="4")]
    pub int_b_data: i32,
    #[prost(int32, tag="5")]
    pub int_data: i32,
}
/// \[RINF:DART-SIGNAL\]
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct MessageOpenFile {
    #[prost(string, tag="1")]
    pub filepath: ::prost::alloc::string::String,
    #[prost(uint32, tag="2")]
    pub height: u32,
    #[prost(uint32, tag="3")]
    pub width: u32,
    #[prost(int32, tag="4")]
    pub byte: i32,
    #[prost(int32, tag="5")]
    pub head: i32,
    #[prost(int32, tag="6")]
    pub tail: i32,
}
/// \[RINF:DART-SIGNAL\]
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct MessagePlayControl {
    #[prost(string, tag="1")]
    pub cmd: ::prost::alloc::string::String,
    #[prost(double, tag="2")]
    pub data: f64,
}
/// \[RINF:RUST-SIGNAL\]
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct MessageRaw {
    #[prost(uint32, tag="1")]
    pub height: u32,
    #[prost(uint32, tag="2")]
    pub width: u32,
    #[prost(int32, tag="3")]
    pub curidx: i32,
    #[prost(int32, tag="4")]
    pub endidx: i32,
    #[prost(uint64, tag="5")]
    pub fps: u64,
}
/// \[RINF:RUST-SIGNAL\]
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct OutputMessage {
    #[prost(int32, tag="1")]
    pub current_number: i32,
    #[prost(uint32, tag="2")]
    pub data: u32,
}
/// \[RINF:RUST-SIGNAL\]
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct OutputImage {
    #[prost(int32, tag="1")]
    pub data: i32,
    #[prost(int32, tag="2")]
    pub rdata: i32,
    #[prost(int32, tag="3")]
    pub gdata: i32,
    #[prost(int32, tag="4")]
    pub bdata: i32,
}
// @@protoc_insertion_point(module)

type InputMessageCell =
    SharedCell<Sender<DartSignal<InputMessage>>>;
pub static INPUT_MESSAGE_SENDER: InputMessageCell =
    OnceLock::new();

impl InputMessage {
    pub fn get_dart_signal_receiver() -> Receiver<DartSignal<Self>> {
        let (sender, receiver) = tokio::sync::mpsc::channel(1024);
        let cell = INPUT_MESSAGE_SENDER
            .get_or_init(|| Mutex::new(RefCell::new(None)))
            .lock()
            .unwrap();
        cell.replace(Some(sender));
        receiver
    }
}

type MessageOpenFileCell =
    SharedCell<Sender<DartSignal<MessageOpenFile>>>;
pub static MESSAGE_OPEN_FILE_SENDER: MessageOpenFileCell =
    OnceLock::new();

impl MessageOpenFile {
    pub fn get_dart_signal_receiver() -> Receiver<DartSignal<Self>> {
        let (sender, receiver) = tokio::sync::mpsc::channel(1024);
        let cell = MESSAGE_OPEN_FILE_SENDER
            .get_or_init(|| Mutex::new(RefCell::new(None)))
            .lock()
            .unwrap();
        cell.replace(Some(sender));
        receiver
    }
}

type MessagePlayControlCell =
    SharedCell<Sender<DartSignal<MessagePlayControl>>>;
pub static MESSAGE_PLAY_CONTROL_SENDER: MessagePlayControlCell =
    OnceLock::new();

impl MessagePlayControl {
    pub fn get_dart_signal_receiver() -> Receiver<DartSignal<Self>> {
        let (sender, receiver) = tokio::sync::mpsc::channel(1024);
        let cell = MESSAGE_PLAY_CONTROL_SENDER
            .get_or_init(|| Mutex::new(RefCell::new(None)))
            .lock()
            .unwrap();
        cell.replace(Some(sender));
        receiver
    }
}

impl MessageRaw {
    pub fn send_signal_to_dart(&self, blob: Option<Vec<u8>>) {
        send_rust_signal(
            3,
            self.encode_to_vec(),
            blob
        );
    }
}

impl OutputMessage {
    pub fn send_signal_to_dart(&self, blob: Option<Vec<u8>>) {
        send_rust_signal(
            4,
            self.encode_to_vec(),
            blob
        );
    }
}

impl OutputImage {
    pub fn send_signal_to_dart(&self, blob: Option<Vec<u8>>) {
        send_rust_signal(
            5,
            self.encode_to_vec(),
            blob
        );
    }
}
