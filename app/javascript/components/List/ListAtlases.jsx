import React, {useEffect, useState} from "react";

import Popup from "../Popup";
import List from "./List";
import Button from "../Button";
import CardAtlas from "./Cards/CardAtlas";

import {useSelector} from "react-redux";
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;


const ListAtlases = () => {
    const {user_id} = useSelector(state => state.user);
    const {token} = useSelector(state => state.session);

    const [activeView, setActiveView] = useState('list');
    const [modal, setModal] = useState(null);

    const [atlases, setAtlases] = useState([]);

    //fetch atlases
    useEffect(() => {
        console.log("token")
        console.log(token)
        fetch('/atlases', {
            method: "GET",
            headers: {
                'X-CSRF-Token': csrfToken,
                Authorization: `Bearer ${token}`
            }
        })
            .then(res => res.json())
            .then(data => {
                if (data.atlases) {
                    setAtlases(data.atlases)
                }
                else {
                    throw new Error(data.errors)
                }


            })
            .catch(err => console.log("LIST ATLASES ERROR" + err.message))
    }, [token]);

    const hideModal = () => {
        setModal(null)
    }

    const onAddAtlas = (e) => {
        e.preventDefault();
        const formData = new FormData(e.target)
        formData.append('user_id', user_id)
        fetch("/atlas", {
            method: "POST",
            body: formData,
            headers: {
                'X-CSRF-Token': csrfToken,
                Authorization: `Bearer ${token}`
            }
        })
            .then(res => res.json())
            .then(data => {
                if (data.errors) {
                    throw new Error(data.errors);
                }
                console.log(data)
                hideModal();
                setAtlases(atlases => [data, ...atlases])
            })
            .catch(err => console.log(err))
    }

    const onDeleteAtlas = (atlasId) => {
        setAtlases(atlases => atlases.filter(atlas => atlas.atlas_id !== atlasId))
    }

    const showModal = () =>  {
        setModal(
            <NewAtlasPopup onClose={hideModal} onAddAtlas={onAddAtlas}/>
        );
    }

    const atlasesHTML = atlases.map( (atlas) => {
        return (
            <CardAtlas
                activeView={activeView}
                key={atlas.atlas_id} atlasId={atlas.atlas_id}
                title={atlas.title} updatedAt={atlas.updated_at}
                atlasImg={atlas.atlas_img} atlasSize={atlas.atlas_size}
                onDeleteAtlas={onDeleteAtlas}
            />
        );
    })

    return (
        <>
            <List activeView={activeView} setActiveView={setActiveView}
                  title="ATLAS " btnTitle="+ New" onAddElem={showModal}>
                {atlasesHTML}
            </List>
            { modal }
        </>
    );
}

const NewAtlasPopup = (props) => {
    return (
        <Popup id="newAtlasPopup" closePopup={props.onClose}>
            <form onSubmit={props.onAddAtlas}>
                <p>New atlas</p>
                <input name="title" required={true} placeholder="atlas filename..."/>
                <Button type="violet">Create</Button>
            </form>
        </Popup>
    );
}

export default ListAtlases;