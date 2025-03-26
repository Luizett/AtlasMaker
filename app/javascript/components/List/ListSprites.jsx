
import React, {useEffect, useState} from "react";
import store from "../../slices/store";
import Popup from "../Popup";
import Button from "../Button";
import List from "./List";


const ListSprites = () => {
    return (
        <>
            <List>

            </List>

        </>
    );
}

export default ListSprites;

const NewSpritePopup = (props) => {
    const [imgPreview, setImgPreview] = useState(null)

    useEffect(() => {
        document.getElementById('sprite-input').click()
    }, []);

    const onNewSprite = (e) => {
        const formData = new FormData(e.target)
        formData.append('user_id', store.getState().user.user_id)
        formData.append('atlas_id',props.atlasId)
        fetch("/sprite", {
            method: "POST",
            body: formData,
            headers: {
                'X-CSRF-Token': csrfToken,
            }
        })
            .then(res => res.json())
            .then(data => {
                data.errors?
                    throw new Error(data.errors)
                    : console.log(data)
            })
            .catch(err => console.log(err))
    };

    return (
        <Popup id="newSpritePopup" closePopup={props.onClose}>
            <form onSubmit={onNewSprite}>
                <p>Your new image</p>
                <label>
                    <input
                        name="img"
                        required={true}
                        id="sprite-input" type="file" accept="image/png, img/jpeg"
                        onChange={(e) => setImgPreview(e.target.value)}/>
                    <img src={imgPreview} alt=""/>
                </label>
                <Button type="violet" btnType="submit">OK</Button>
            </form>
        </Popup>
    );
}