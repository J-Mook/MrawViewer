// #[cfg(target_os = "windows")]
// use std::os::windows::thread;
// #[cfg(target_os = "macos")]
// use std::os::unix::thread;

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
        current_idx: i32,
        total_idx: i32,
    }
    let a_playstate = Arc::new(Mutex::new(s_playstate {
            opened: false,
            play: false,
            current_idx: 0,
            total_idx: 1,
        }));
    
    // let a_playstate2 = Arc::clone(&a_playstate);
    // let a_mrawinfo2 = Arc::clone(&a_mrawinfo);
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
                state.total_idx = data.len() as i32;
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

            if _cmd == "Exit" {
                std::process::exit(1);
            }
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
                state.current_idx = msg.data as i32;
            }
            if _cmd == "Inc" {
                state.current_idx += 1;
                if state.current_idx >= state.total_idx - 1 { state.current_idx = 0; }
            }
            if _cmd == "Dec" {
                state.current_idx -= 1;
                if state.current_idx <= 0 {  state.current_idx = state.total_idx.clone() - 1; }
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
                state.total_idx = 1;
            }
            if _cmd == "Encoding" {
                let framedata_arc_clone = Arc::clone(&info.framedata);
                make_mp4(&framedata_arc_clone, info.width, info.height);
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
                if sss < 33 { std::thread::sleep(Duration::from_millis(33 - sss)); }

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

    if let Ok(_) = File::open(filepath.clone()) {

        let bytes: Vec<u8> = std::fs::read(filepath).unwrap();
        let mut frame: Vec<u16> = Vec::with_capacity(frame_size);
    
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
                let pix = (256 * (xxx + vvv) / width) % 256;
                image_data[vvv as usize][((width * yyy + xxx)) as usize] = (pix * 64) as u16;
            }
        }
    }
    return Some(image_data);
}

fn load_frame(framebuf:&Vec<Vec<u16>>, width: u32, height: u32, idx: i32) -> Option<Vec<u8>>{
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

pub fn make_mp4(framebuf:&Vec<Vec<u16>>, width: u32, height: u32) {
    
    // use image::{GrayImage, Luma};
    // use std::path::Path;
    // for (index, frame) in framebuf.into_iter().enumerate() {
    //     // Vec<u16>를 GrayImage로 변환
    //     let img = GrayImage::from_fn(width, height, |x, y| {
    //         let pixel_index = (y * width + x) as usize;
    //         Luma([frame[pixel_index] as u8])
    //     });

    //     // 이미지 파일로 저장
    //     let file_name = format!("C:\\frames\\framesss_{:03}.png", index);
    //     let _res = img.save(Path::new(&file_name));
    //     match _res {
    //         Ok(_) => print!("saved {}\n", file_name),
    //         Err(_) => print!("failed {}\n", file_name)
    //     }
    // }

    // Ok(())
    

    /////////////////////////////////////////////////////////////////////////////


    // extern crate ffmpeg_next as ffmpeg;
    
    // use ffmpeg::{
    //     codec, format, util::frame::video::Video,
    //     // codec, format, media, packet, software::scaling::{Context, flag::Flags}, util::frame::video::Video,
    // };

    // let _ = ffmpeg::init();

    // let mut octx = format::output(&"C:\\output.mp4").unwrap();
    // // let codec = ffmpeg::codec::encoder::find_encoder_by_name("libx264").ok_or("Codec not found");
    // let codec = codec::encoder::find(codec::Id::H264);
    
    // let mut ost = octx.add_stream(codec).unwrap();
    
    // // let mut encoder = codec::encoder::video::Video::from_parameters(ost.parameters())?;
    // let mut vencoder = codec::context::Context::from_parameters(ost.parameters()).unwrap().encoder().video().unwrap();
    // vencoder.set_height(height);
    // vencoder.set_width(width);
    // vencoder.set_format(ffmpeg_next::util::format::pixel::Pixel::RGB24);
    // ost.set_parameters(&vencoder);
    // // vencoder.open();
    
    // // let mut scaler = Context::get(
    // //     // codec::context::input(&encoder),
    // //     // codec::context::output(&encoder),
    // //     // Flags::BILINEAR,
    // //     vencoder.format(),
    // //     vencoder.width(),
    // //     vencoder.height(),
    // //     ffmpeg_next::util::format::pixel::Pixel::RGB24,
    // //     vencoder.width(),
    // //     vencoder.height(),
    // //     Flags::BILINEAR,
    // // ).unwrap();

    // let mut frame = Video::empty();
    // frame.set_format(ffmpeg_next::util::format::pixel::Pixel::RGB24);
    // frame.set_width(width);
    // frame.set_height(height);

    // for (i, frame_data) in framebuf.iter().enumerate() {

    //     frame.set_pts(Some(i as i64));

    //     let mut rgb_frame = Video::empty();
    //     rgb_frame.set_format(ffmpeg::util::format::pixel::Pixel::RGB24);
    //     rgb_frame.set_width(width);
    //     rgb_frame.set_height(height);

    //     for (idx, pixel) in frame_data.iter().enumerate() {
    //         let gray_value = (pixel / 64) as u8;

    //         rgb_frame.data_mut(0)[idx * 3 + 0] = gray_value; // R
    //         rgb_frame.data_mut(0)[idx * 3 + 1] = gray_value; // G
    //         rgb_frame.data_mut(0)[idx * 3 + 2] = gray_value; // B
    //     }
        
    //     if vencoder.send_frame(&rgb_frame).is_ok() {
    //         let mut encoded = ffmpeg::Packet::empty();
    //         while let Ok(_) = vencoder.receive_packet(&mut encoded) {
    //             // octx.write_frame(&encoded).unwrap();
    //             encoded.write_interleaved(&mut octx).unwrap();
    //         }
    //     }
    // }

    // // encoder.send_eof();
    // // while let Ok(packet) = encoder.receive_packet() {
    // //     octx.write_frame(&packet)?;
    // // }

    // // octx.write_trailer();

    // // vencoder.send_eof();
    // // let mut encoded = ffmpeg::Packet::empty();
    // // while let Ok(_) = vencoder.receive_packet(&mut encoded) {
    // //     encoded.write_interleaved(&mut octx).unwrap();
    // // }

    // octx.write_trailer().unwrap();

    // // Ok(())


    /////////////////////////////////////////////////////////////////////////////


    // use video_rs::encode::{Encoder, Settings};
    // use video_rs::time::Time;
    // use std::path::Path;
    // extern crate ffmpeg_next as ffmpeg;
    // use ffmpeg::{
    //     codec, format, media, packet, software::scaling::{Context, flag::Flags}, util::frame::video::Video,
    // };

    // // video_rs::init().unwrap();

    // let settings = Settings::preset_h264_yuv420p(640, 480, false);
    // // let settings = Settings::preset_h264_yuv420p(640, 480, video_rs::ffmpeg::format::Pixel::RGB24);
    // let mut v_encoder =
    //     Encoder::new(Path::new("rainbow.mp4"), settings).expect("failed to create encoder");

    // let duration: Time = Time::from_nth_of_a_second(24);
    // let mut position = Time::zero();
    // for rawframe in framebuf {

    //     let mut rgb_frame = Video::empty();
    //     rgb_frame.set_format(ffmpeg::util::format::pixel::Pixel::RGB24);
    //     rgb_frame.set_width(width);
    //     rgb_frame.set_height(height);

    //     for (idx, pixel) in rawframe.iter().enumerate() {
    //         let gray_value = (pixel / 64) as u8;

    //         rgb_frame.data_mut(0)[idx * 3 + 0] = gray_value; // R
    //         rgb_frame.data_mut(0)[idx * 3 + 1] = gray_value; // G
    //         rgb_frame.data_mut(0)[idx * 3 + 2] = gray_value; // B
    //     }

    //     v_encoder.encode_raw(rgb_frame);
    //     // encoder
    //     //     .encode(&rgbframe, &position)
    //     //     .expect("failed to encode frame");

    //     // Update the current position and add the inter-frame duration to it.
    //     position = position.aligned_with(&duration).add();
    // }

    // v_encoder.finish().expect("failed to finish encoder");

    ////////////////////////////////////////////////////////////////////////////////////

    // use opencv::{ core, imgproc, prelude::*, videoio };

    // // MP4V 코덱과 비디오 작성자 초기화
    // let fourcc = videoio::VideoWriter::fourcc('M' as i8, 'P' as i8, '4' as i8, 'V' as i8)?;
    // let mut writer = videoio::VideoWriter::new("C:\\output.mp4", fourcc, fps, core::Size::new(width, height), true)?;

    // for frame_data in framebuf.iter() {
    //     // OpenCV의 Mat 객체를 생성하여 프레임 데이터를 저장
    //     let mut frame = core::Mat::new_rows_cols_with_default(height, width, core::CV_8UC3, core::Scalar::new(0.0, 0.0, 0.0, 0.0))?;

    //     for (idx, &pixel) in frame_data.iter().enumerate() {
    //         let gray_value = (pixel / 64) as u8;
    //         let color = core::Scalar::new(gray_value as f64, gray_value as f64, gray_value as f64, 0.0);

    //         // 각 픽셀의 위치 계산 (단순화된 예제)
    //         let x = idx % width;
    //         let y = idx / width;

    //         // 단일 픽셀에 색상 적용
    //         imgproc::circle(&mut frame, core::Point::new(x as i32, y as i32), 1, color, -1, imgproc::LINE_8, 0)?;
    //     }

    //     // 프레임을 비디오에 추가
    //     writer.write(&frame)?;
    // }

    // print!("saved!!!!\n")
}