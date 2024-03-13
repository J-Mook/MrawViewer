#[cfg(target_os = "windows")]
use std::os::windows::thread;
#[cfg(target_os = "macos")]
use std::os::unix::thread;

use std::{sync::{Arc, Mutex}, time::Duration};
use tokio_with_wasm::tokio;
use image::ImageEncoder;

const WIDTH: u32 = 256;
const HEIGHT: u32 = 256;
const BUF_SIZE: u32 = WIDTH * HEIGHT * 3;

const SHOULD_DEMONSTRATE: bool = true;


mod messages;
rinf::write_interface!();

// Always use non-blocking async functions
// such as `tokio::fs::File::open`.
// If you really need to use blocking code,
// use `tokio::task::spawn_blocking`.
async fn main() {

    // tokio::spawn(numberCnt());
    tokio::spawn(stream_rgb_image());
    tokio::spawn(stream_mraw_image());
    // stream_rgb_image();
}



pub async fn stream_mraw_image(){

    use messages::mooksviewer::*;
    use std::fs::File;
    use std::io::{self, BufReader, Read};
    use std::path::Path;
    use byteorder::{LittleEndian, ReadBytesExt};

    #[derive(Clone)]
    struct s_mrawinfo {
        filepath: String,
        height: u32,
        width: u32,
        byte: i32,
        head: i32,
        tail: i32,
        framedata: Vec<Vec<u16>>
    }
    let a_mrawinfo = Arc::new(Mutex::new(s_mrawinfo {
        filepath: "".to_string(),
        height: 0,
        width: 0,
        byte: 0,
        head: 0,
        tail: 0,
        framedata: Vec::new()
    }));
    
    #[derive(Clone)]
    struct s_playstate {
        opened: bool,
        play: bool,
        current_idx: u32,
        total_idx: u32,
    }
    let a_playstate = Arc::new(Mutex::new(s_playstate {
        opened: false,
        play: false,
        current_idx: 0,
        total_idx: 0,
    }));
    
    let a_playstate2 = Arc::clone(&a_playstate);
    let a_mrawinfo2 = Arc::clone(&a_mrawinfo);
    let a_playstate3 = Arc::clone(&a_playstate);
    let a_mrawinfo3 = Arc::clone(&a_mrawinfo);
    let a_playstate4 = Arc::clone(&a_playstate);
    let a_mrawinfo4 = Arc::clone(&a_mrawinfo);

    let mut _fileopenrecvier: tokio::sync::mpsc::Receiver<rinf::DartSignal<MessageOpenFile>> = MessageOpenFile::get_dart_signal_receiver();
    tokio::spawn(async move {
        while let Some(dart_signal) = _fileopenrecvier.recv().await {
            let mut state = a_playstate.lock().unwrap();
            let mut info = a_mrawinfo.lock().unwrap();
            
            let msg = dart_signal.message;
            let fp = msg.filepath.clone();
            info.filepath = msg.filepath;
            info.height = msg.height;
            info.width = msg.width;
            info.byte = msg.byte;
            info.head = msg.head;
            info.tail = msg.tail;
            
            if let Ok(file) = File::open(info.filepath.clone()) {
                if let Some(data) = load_image_file(info.filepath.clone(), info.height, info.width) {
                    info.framedata = data.clone();
                    state.total_idx = data.len() as u32;
                    state.opened = true;
                }
            } else {
                state.opened = false;
                info.framedata = make_test_pattern(info.height, info.width).unwrap();
                state.total_idx = 256;
            }
            
            state.current_idx = 0;
            // print!(format!("{}", msg.filepath));
            // println!("{}", fp);

        }
    });

    let mut _filecontrolrecvier: tokio::sync::mpsc::Receiver<rinf::DartSignal<MessagePlayControl>> = MessagePlayControl::get_dart_signal_receiver();
    tokio::spawn(async move {
        while let Some(dart_signal) = _filecontrolrecvier.recv().await {
            let mut state = a_playstate3.lock().unwrap();
            let mut info = a_mrawinfo3.lock().unwrap();
            
            let msg = dart_signal.message;
            let _cmd = msg.cmd;

            if _cmd == "Play" {
                state.play = true;
            }
            if _cmd == "Puase" {
                state.play = false;
            }
            if _cmd == "Stop" {
                state.current_idx = 0;
                state.play = false;
            }
            if _cmd == "Close" {
                state.current_idx = 0;
                state.total_idx = 0;
                state.play = false;
                state.opened = false;
                info.framedata.clear();
                // info.filepath = "";
                info.height = 0;
                info.width = 0;
            }
            println!("recv cmd : {}", _cmd);
        }
    });

    // let t_handler = std::thread::spawn( move || {
    //     loop {
    
    //         let mut state = a_playstate4.lock().unwrap();
    //         let info = a_mrawinfo4.lock().unwrap();
    //         let _wid = info.width.clone();
    //         let _hit = info.height.clone();
            
    //         if _wid != 0 && _hit != 0 {
    //             MessageRaw {
    //                 height: _hit,
    //                 width: _wid
    //             }.send_signal_to_dart(load_frame(info.framedata.clone(), info.width, info.height, state.current_idx));
                
    //             if state.play { state.current_idx += 1; }
    //             if state.current_idx >= state.total_idx { state.current_idx = 0; }
    //             if state.current_idx < 0 { state.current_idx = 0; }

    //             println!("{}/{} w{} h{}", state.current_idx, state.total_idx, _wid, _hit);

    //             std::thread::sleep(Duration::from_millis(10));
    //         }
    //     }
    // });
// t_handler.join().unwrap();


    tokio::spawn(async move {
        loop {
            tokio::time::sleep(std::time::Duration::from_millis(2)).await;

            let mut state = a_playstate2.lock().unwrap();
            let info = a_mrawinfo2.lock().unwrap();
            let _wid = info.width.clone();
            let _hit = info.height.clone();
            
            if _wid != 0 && _hit != 0 {
                MessageRaw {
                    height: _hit,
                    width: _wid
                }.send_signal_to_dart(load_frame(info.framedata.clone(), info.width, info.height, state.current_idx));
                
                if state.play { state.current_idx += 1; }
                if state.current_idx >= state.total_idx { state.current_idx = 0; }
                if state.current_idx < 0 { state.current_idx = 0; }

                println!("{}/{} w{} h{}", state.current_idx, state.total_idx, _wid, _hit);
            }
        }
    });

    // let (sender, mut receiver) = tokio::sync::mpsc::channel(5);
    // tokio::spawn(async move {
    //     loop {
    //         tokio::time::sleep(std::time::Duration::from_millis(10)).await;
                
    //         if sender.capacity() == 0 {
    //             continue;
    //         }

    //         let _wid;
    //         let _hit: u32;
    //         let frame;
    //         {
    //             let mut state = a_playstate2.lock().unwrap();
    //             let info = a_mrawinfo2.lock().unwrap();

    //             _wid = info.width.clone();
    //             _hit = info.height.clone();
    //             frame = load_frame(info.framedata.clone(), info.width, info.height, state.current_idx);

    //             if state.play { state.current_idx += 1; }
    //             if state.current_idx >= state.total_idx { state.current_idx = 0; }
    //             if state.current_idx < 0 { state.current_idx = 0; }
    //             println!("{}/{} w{} h{}", state.current_idx, state.total_idx, _wid, _hit);
    //         }

    //         if _wid != 0 && _hit != 0 {
    //             let join_handle = tokio::task::spawn_blocking(move || {
    //                 return (_wid, _hit, frame)
    //             });
    //             let _ = sender.send(join_handle).await;
    //         }
    //     }
    // });

    // tokio::spawn(async move {
    //     loop {
    //         if let Some(join_handle) = receiver.recv().await {
    //             let received_frame = join_handle.await.unwrap();
    //             if let (_wid, _hit, Some(image)) = received_frame {
    //                 // Stream the image data to Dart.
    //                 MessageRaw {
    //                     height: _hit,
    //                     width: _wid
    //                 }.send_signal_to_dart(Some(image));
    //                 // println!("Send!!! w{} h{}",  _wid, _hit);
    //             };
    //         }
    //     }
    // });
}

fn load_image_file(filepath: String, width: u32, height: u32) -> Option<Vec<Vec<u16>>>{
    let mut image_data: Vec<Vec<u16>> = [].to_vec();
    let frame_size = (width * height) as usize;

    let bytes: Vec<u8> = std::fs::read(filepath).unwrap();
        let mut frame: Vec<u16> = Vec::with_capacity(frame_size);
        let mut idx = 0;

        for byte_pair in bytes.chunks_exact(2) {
            // let short = u16::from_le_bytes([byte_pair[0], byte_pair[1]]);
            let short = ((byte_pair[1] as u16) << 8) | byte_pair[0] as u16;
            frame.push(short);

            if frame.len() == frame_size {
                image_data.push(frame);
                frame = Vec::with_capacity(frame_size);
            }
        }

        if !frame.is_empty() {
            image_data.push(frame);
        }
        
        match image_data.is_empty() {
            true => Some(image_data),
            false => None,
        }
}

fn make_test_pattern(width: u32, height: u32) -> Option<Vec<Vec<u16>>>{
    let mut image_data: Vec<Vec<u16>> = (0..256).map(|_| vec![0u16; (width * height) as usize]).collect();
    
    for vvv in 0..256 {
        for yyy in 0..height {
            for xxx in 0..width {
                let mut pix = vvv;
                pix = (256 * xxx / width + vvv) % 256;
                image_data[vvv as usize][((width * yyy + xxx)) as usize] = (pix * 64) as u16;
            }
        }
    }
    return Some(image_data);
}

fn load_frame(framebuf:Vec<Vec<u16>>, width: u32, height: u32, idx: u32) -> Option<Vec<u8>>{
    let mut image_data: Vec<u8> = Vec::new();
    let mut buffer: Vec<u8> = vec![0; (width * height * 3) as usize];
    
    for yyy in 0..height {
        for xxx in 0..width {

            let pixel_value16 = framebuf[idx as usize][((width * yyy + xxx)) as usize];
            let pixel_value8 = (pixel_value16 / 64) as u8;

            let r_value = pixel_value8;
            let g_value = pixel_value8;
            let b_value = pixel_value8;

            buffer[(((width * yyy + xxx) * 3) + 0) as usize] = std::cmp::max(0, std::cmp::min(r_value, 255)) as u8;
            buffer[(((width * yyy + xxx) * 3) + 1) as usize] = std::cmp::max(0, std::cmp::min(g_value, 255)) as u8;
            buffer[(((width * yyy + xxx) * 3) + 2) as usize] = std::cmp::max(0, std::cmp::min(b_value, 255)) as u8;
        }
    }

    let encoder: image::codecs::png::PngEncoder<&mut Vec<u8>> = image::codecs::png::PngEncoder::new(&mut image_data);
    let result = encoder.write_image(buffer.as_slice(), width, height, image::ColorType::Rgb8.into());

    match result {
        Ok(_) => Some(image_data),
        Err(_) => None,
    }
}



struct SharedState {
    cur_r_num: i32,
    cur_g_num: i32,
    cur_b_num: i32,
    play: bool,
}

pub async fn stream_rgb_image() {

    use messages::mooksviewer::*;

    let shared_state = Arc::new(Mutex::new(SharedState {
        cur_r_num: 0,
        cur_g_num: 0,
        cur_b_num: 0,
        play: false,
    }));


    if !SHOULD_DEMONSTRATE {
        return;
    }

    let shared_state1 = Arc::clone(&shared_state);
    let mut _inreceiver: tokio::sync::mpsc::Receiver<rinf::DartSignal<InputMessage>> = InputMessage::get_dart_signal_receiver();
    tokio::spawn(async move {
        while let Some(dart_signal) = _inreceiver.recv().await {
            let msg = dart_signal.message;
            let msgcmd = msg.cmd;
            
            let mut s = shared_state1.lock().unwrap();

            if msgcmd == String::from("+")  {
                s.cur_r_num += 1;
                s.cur_g_num += 1;
                s.cur_b_num += 1;
            }
            if msgcmd == String::from("-")  {
                s.cur_r_num -= 1;
                s.cur_g_num -= 1;
                s.cur_b_num -= 1;
            }
            if msgcmd == String::from("Reset") || msgcmd == String::from("R") {
                s.cur_r_num = 0;
                s.cur_g_num = 0;
                s.cur_b_num = 0;
            }

            if msgcmd == String::from("SetRGB")  {
                s.cur_r_num = msg.int_r_data;
                s.cur_g_num = msg.int_g_data;
                s.cur_b_num = msg.int_b_data;
            }

            if msgcmd == String::from("Play")  {
                s.play = true;
            }
            if msgcmd == String::from("Stop")  {
                s.play = false;
            }

            OutputMessage{
                current_number: s.cur_r_num,
                data: 0,
            }.send_signal_to_dart(None);
        }
    });

    let shared_state2 = Arc::clone(&shared_state);
    tokio::spawn(async move {
        loop {

            tokio::time::sleep(std::time::Duration::from_millis(33)).await;

            let mut s = shared_state2.lock().unwrap();
            if s.play {
                s.cur_r_num += 1;
                s.cur_g_num += 1;
                s.cur_b_num += 1;
                if s.cur_r_num > 256 { s.cur_r_num = 0; }
                if s.cur_g_num > 256 { s.cur_g_num = 0; }
                if s.cur_b_num > 256 { s.cur_b_num = 0; }
            }

            OutputImage {
                data: 0,
                rdata: s.cur_r_num,
                gdata: s.cur_g_num,
                bdata: s.cur_b_num,
            }.send_signal_to_dart(draw_image(s.cur_r_num, s.cur_g_num, s.cur_b_num, HEIGHT, WIDTH));

        }
    });

}

pub fn draw_image(r_value: i32, g_value: i32, b_value: i32, height: u32, width: u32) -> Option<Vec<u8>>{
    let mut image_data: Vec<u8> = Vec::new();
    let mut buffer: Vec<u8> = vec![0; (width * height * 3) as usize];
    // let mut buffer: Vec<u8> = vec![0; BUF_SIZE as usize];

    for yyy in 0..height {
        for xxx in 0..width {
            buffer[(((width * yyy + xxx) * 3) + 0) as usize] = std::cmp::max(0, std::cmp::min(r_value, 256)) as u8;
            buffer[(((width * yyy + xxx) * 3) + 1) as usize] = std::cmp::max(0, std::cmp::min(g_value, 256)) as u8;
            buffer[(((width * yyy + xxx) * 3) + 2) as usize] = std::cmp::max(0, std::cmp::min(b_value, 256)) as u8;
        }
    }

    let encoder = image::codecs::png::PngEncoder::new(&mut image_data);
    let result = encoder.write_image(buffer.as_slice(), width, height, image::ColorType::Rgb8.into());

    match result {
        Ok(_) => Some(image_data),
        Err(_) => None,
    }
}