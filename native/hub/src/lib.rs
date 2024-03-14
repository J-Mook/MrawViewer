#[cfg(target_os = "windows")]
use std::os::windows::thread;
#[cfg(target_os = "macos")]
use std::os::unix::thread;

use std::sync::{Arc, Mutex};
use tokio_with_wasm::tokio;
use image::ImageEncoder;
use std::fs::File;

use std::time::{Duration, Instant};


// const WIDTH: u32 = 256;
// const HEIGHT: u32 = 256;
// const BUF_SIZE: u32 = WIDTH * HEIGHT * 3;

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

    #[derive(Clone)]
    struct s_mrawinfo {
        filepath: String,
        height: u32,
        width: u32,
        byte: i32,
        head: i32,
        tail: i32,
        framedata: Arc<Vec<Vec<u16>>>
    }
    let a_mrawinfo = Arc::new(Mutex::new(s_mrawinfo {
            filepath: "".to_string(),
            height: 0,
            width: 0,
            byte: 0,
            head: 0,
            tail: 0,
            framedata: Arc::new(Vec::new()),
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
            info.filepath = msg.filepath;
            info.height = msg.height;
            info.width = msg.width;
            info.byte = msg.byte;
            info.head = msg.head;
            info.tail = msg.tail;

            state.opened = false;
            state.play = false;
            state.current_idx = 0;
            state.total_idx = 0;
            
            if let Some(data) = load_image_file(info.filepath.clone(), info.height, info.width) {
                state.total_idx = data.len() as u32;
                info.framedata = Arc::new(data);
                state.opened = true;
            } else {
                state.opened = false;
                info.framedata = Arc::new(make_test_pattern(info.height, info.width).unwrap());
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
            if _cmd == "Pause" {
                state.play = false;
            }
            if _cmd == "Stop" {
                state.current_idx = 0;
                state.play = false;
            }
            if _cmd == "Jump" {
                state.current_idx = msg.data as u32;
            }
            if _cmd == "Close" {
                info.filepath = "".to_string();
                info.height = 0;
                info.width = 0;
                info.byte = 0;
                info.head = 0;
                info.tail = 0;
                info.framedata = Arc::new(Vec::new());

                state.opened = false;
                state.play = false;
                state.current_idx = 0;
                state.total_idx = 0;
            }
            println!("recv cmd : {}", _cmd);
        }
    });

    std::thread::spawn( move || {
        loop {
            
            let info: std::sync::MutexGuard<'_, s_mrawinfo> = a_mrawinfo4.lock().unwrap();
            let framedata_arc_clone = Arc::clone(&info.framedata);
            let _width = info.width.clone();
            let _height = info.height.clone();
            drop(info);
            
            if _width != 0 && _height != 0 {
                let start = Instant::now();
                
                let state: std::sync::MutexGuard<'_, s_playstate> = a_playstate4.lock().unwrap();
                let mut _state = state.clone();
                drop(state);
                
                let frameimage = load_frame(&framedata_arc_clone, _width, _height, _state.current_idx);

                let sss = start.elapsed().as_millis() as u64;
                if (sss < 33) { std::thread::sleep(Duration::from_millis(33 - sss)); }

                MessageRaw { 
                    height: _height,
                    width: _width,
                    curidx: _state.current_idx,
                    endidx: _state.total_idx,
                    fps: sss ,
                }.send_signal_to_dart(frameimage);
                
                if _state.play {
                    _state.current_idx += 1;
                    if _state.current_idx >= _state.total_idx { _state.current_idx = 0; }
                    
                    let mut state = a_playstate4.lock().unwrap();
                    state.current_idx = _state.current_idx;
                    drop(state);
                }
                
                // println!("{}/{} w{} h{} {}ms", _state.current_idx, _state.total_idx, _width, _height, start.elapsed().as_millis());
            }
            else{
                std::thread::sleep(Duration::from_millis(10));
            }
        }
    });
}

fn load_image_file(filepath: String, width: u32, height: u32) -> Option<Vec<Vec<u16>>>{
    let mut image_data: Vec<Vec<u16>> = Vec::new();
    let frame_size = (width * height) as usize;

    if let Ok(file) = File::open(filepath.clone()) {

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
    }

    match !image_data.is_empty() {
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

fn load_frame(framebuf:&Vec<Vec<u16>>, width: u32, height: u32, idx: u32) -> Option<Vec<u8>>{
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

    
    // let encoder = image::codecs::png::PngEncoder::new(&mut image_data); // 120millisec
    // let encoder = image::codecs::jpeg::JpegEncoder::new(&mut image_data); // 60millisec
    let encoder = image::codecs::bmp::BmpEncoder::new(&mut image_data); // 5millisec
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
            }.send_signal_to_dart(draw_image(s.cur_r_num, s.cur_g_num, s.cur_b_num, 256, 256));

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