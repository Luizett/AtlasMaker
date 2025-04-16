import React, {useEffect, useState} from "react";
import useFetch from "../../services/useFetch";

import {useSelector} from "react-redux";

import Popup from "../Popup";
import List from "./List";
import Button from "../Button";
import CardAtlas from "./Cards/CardAtlas";


const ListAtlases = () => {
    const {user_id} = useSelector(state => state.user);

    const [activeView, setActiveView] = useState('list');
    const [modal, setModal] = useState(null);
    const [atlases, setAtlases] = useState([]);

    const {request} = useFetch();

    useEffect(() => {
        request("/atlases", "GET")
            .then(data => {
                setAtlases(data.atlases)
            })
            .catch(err => console.log("Error in ListAtlases: " + err))

    }, []);

    const hideModal = () => {
        setModal(null)
    }

    const onAddAtlas = (e) => {
        e.preventDefault();

        let requestBody = new FormData(e.target)
        requestBody.append('user_id', user_id)

        request("/atlas", "POST", requestBody)
            .then(data => {
                hideModal();
                setAtlases(atlases => [data, ...atlases])
            })
            .catch(err => console.log(err))
    }

    const onDeleteAtlas = (atlasId) => {
        let requestBody = new FormData();
        requestBody.append('atlas_id', atlasId);

        request("/atlas", "DELETE", requestBody)
            .then(data => {
                setAtlases(atlases => atlases.filter(atlas => atlas.atlas_id !== atlasId))
            })
            .catch(err => console.log("Error in deleteAtlas: " + err))
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