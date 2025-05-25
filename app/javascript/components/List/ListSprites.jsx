import React, {useEffect, useState} from "react";
import useFetch from "../../services/useFetch";

import {useDispatch, useSelector} from "react-redux";
import {updateAtlasImage} from "../../slices/atlasSlice";

import Popup from "../Popup";
import Button from "../Button";
import List from "./List";
import CardSprite from "./Cards/CardSprite";

const ListSprites = () => {
    const {atlas_id} = useSelector(state => state.atlas)
    const [activeView, setActiveView] = useState('gallery');
    const [modal, setModal] = useState(null);
    const [sprites, setSprites] = useState([]);

    const dispatch = useDispatch();
    const {request} = useFetch();

    //fetch cards
    useEffect(() => {
        if (atlas_id) {
            request(`/atlas/${atlas_id}/sprites`, "GET")
                .then(data => {
                    setSprites(data.sprites)
                })
                .catch(err => console.log("Error in ListSprites: " + err))
        }
    }, [atlas_id]);

    const hideModal = () => {
        setModal(null)
    }

    const onAddSprite = (e) => {
        e.preventDefault();

        let requestBody = new FormData(e.target)
        requestBody.append('atlas_id', atlas_id)

        request("/sprite", "POST", requestBody)
            .then(data => {
                hideModal();
                dispatch(updateAtlasImage(data.atlas_img))
                setSprites(sprites => [ ...sprites, data.sprite])
            })
            .catch(err => console.log("Error in onAddSprite: " + err))
    }

    const onDeleteSprite = (spriteId) => {
        let requestBody = new FormData();
        requestBody.append('sprite_id', spriteId);
        requestBody.append('atlas_id', atlas_id);

        request("/sprite", "DELETE", requestBody)
            .then(data => {
                dispatch(updateAtlasImage(data.atlas_img))
                setSprites(sprites => sprites.filter(sprite => sprite.sprite_id !== spriteId))
            })
            .catch(err => console.log("Error in deleteAtlas: " + err))
    }


    const showModal = () =>  {
        setModal(
            <NewSpritePopup onClose={hideModal} onAddSprite={onAddSprite}/>
        );
    }

    const spritesHTML = sprites.map( (sprite) => {
        return (
            <CardSprite
                activeView={activeView}
                key={sprite.sprite_id} spriteId={sprite.sprite_id}
                title={sprite.filename}
                spriteImg={sprite.sprite_img}
                onDeleteSprite={onDeleteSprite}
            />
        );
    })

    return (
        <>
            <List activeView={activeView} setActiveView={setActiveView}
                  title="IMAGES " btnTitle="+ Add" onAddElem={showModal}>
                {spritesHTML}
            </List>
            { modal }
        </>
    );
}

export default ListSprites;

const NewSpritePopup = (props) => {
    const [imgPreview, setImgPreview] = useState(null)

    useEffect(() => {
        document.getElementById('sprite-input').click()
    }, []);


    return (
        <Popup id="newSpritePopup" closePopup={props.onClose}>
            <form onSubmit={props.onAddSprite} className="flex flex-col  items-center">
                <label className="text-center">
                    Choose image...
                    <input
                        name="img"
                        required={true}
                        className="hidden"
                        id="sprite-input" type="file" accept="image/png, img/jpeg"
                        onChange={(e) => setImgPreview(URL.createObjectURL(e.target.files[0]))}/>
                    <img src={imgPreview} alt="" className="mx-auto mt-4 bg-clip-content  border-pink border-dashed border-2  text-center rounded-md p-4" style={{
                        backgroundImage: `url(\"/images/transparent.png\")`,
                        backgroundSize: "cover",
                    }}/>
                </label>
                <Button type="violet" btnType="submit" className="mt-4 w-min">
                    OK
                </Button>
            </form>
        </Popup>
    );
}