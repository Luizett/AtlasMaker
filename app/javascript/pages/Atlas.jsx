import React, {useState} from "react";
import Header from "./_Header";

const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

const Atlas = () => {
    const [atlas, setAtlas] = useState(null);
    const [img1, setImg1] = useState(null);
    const [img2, setImg2] = useState(null);
    return (
        <>
            <Header/>
            <div className="bg-russian-violet text-white">
                <img src={atlas} alt="your atlas image"/>
                <input type="file" accept="image/png, image/jpeg"
                       onChange={(e) => setImg1(e.target.files[0])}/>
                <input type="file" accept="image/png, image/jpeg"
                       onChange={(e) => setImg2(e.target.files[0])}/>
                <button onClick={() => {
                    const formData = new FormData();
                    formData.append('img1', img1);
                    formData.append('img2', img2);
                    fetch("/images", {
                        method: 'POST',
                        body: formData,
                        headers: {
                            'X-CSRF-Token': csrfToken,
                        },
                    })
                        .then(res => res.blob())
                        .then(blob => URL.createObjectURL(blob))
                        .then(url => setAtlas(url));
                }}>Make atlas</button>
            </div>

        </>
    );
}

export default Atlas;