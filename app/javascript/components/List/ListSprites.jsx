
import React, {useEffect, useState} from "react";
import {useDispatch, useSelector} from "react-redux";
import {updateAtlasImage} from "../../slices/atlasSlice";

import Popup from "../Popup";
import Button from "../Button";
import List from "./List";
import CardSprite from "./Cards/CardSprite";

const csrfToken = document.querySelector('meta[name="csrf-token"]').content;


const ListSprites = () => {
    const {token} = useSelector(state => state.session);
    const {atlas_id} = useSelector(state => state.atlas)
    const [activeView, setActiveView] = useState('gallery');
    const [modal, setModal] = useState(null);
    const dispatch = useDispatch();

    const [sprites, setSprites] = useState([]);

    //fetch cards
    useEffect(() => {
        if (atlas_id) {
            fetch(`/atlas/${atlas_id}/sprites`, {
                method: "GET",
                headers: {
                    'X-CSRF-Token': csrfToken,
                    Authorization: `Bearer ${token}`
                }
            })
                .then(res => res.json())
                .then(data => {
                    if (data.error || data.errors) {
                        throw new Error(data)
                    }
                    setSprites(data.sprites)
                })
                .catch(err => console.log("Error in ListSprites: " + err.error + err.errors))
        }
    }, [atlas_id]);

    const hideModal = () => {
        setModal(null)
    }

    const onAddSprite = (e) => {
        e.preventDefault();
        const formData = new FormData(e.target)
        formData.append('atlas_id', atlas_id)
        fetch("/sprite", {
            method: "POST",
            body: formData,
            headers: {
                'X-CSRF-Token': csrfToken,
                Authorization: `Bearer ${token}`
            }
        })
            .then(res => res.json())
            .then(data => {
                if (data.error) {
                    throw new Error(data.error);
                }
               // console.log(data)
                hideModal();
                dispatch(updateAtlasImage(data.atlas_img))
                setSprites(sprites => [ ...sprites, data.sprite])
            })
            .catch(err => console.log("Error in onAddSprite: " + err))
    }

    const onDeleteSprite = (spriteId) => {
        let formData = new FormData();
        formData.append('sprite_id', spriteId);
        formData.append('atlas_id', atlas_id);
        fetch("/sprite", {
            method:"DELETE",
            body: formData,
            headers: {
                'X-CSRF-Token': csrfToken,
                Authorization: `Bearer ${token}`
            }
        })
            .then(res => res.json())
            .then(data => {
                if (!data.message)
                { throw new Error(data.error + data.errors)}
                else
                {
                    dispatch(updateAtlasImage(data.atlas_img))
                    setSprites(sprites => sprites.filter(sprite => sprite.sprite_id !== spriteId))
                    // onDeleteSprite(spriteId)
                    console.log(data)
                }
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
            <form onSubmit={props.onAddSprite}>
                <p>Your new image</p>
                <label>
                    <input
                        name="img"
                        required={true}
                        id="sprite-input" type="file" accept="image/png, img/jpeg"
                        onChange={(e) => setImgPreview(URL.createObjectURL(e.target.files[0]))}/>
                    <img src={imgPreview} alt=""/>
                </label>
                <Button type="violet" btnType="submit">
                    OK
                </Button>
            </form>
        </Popup>
    );
}