import React, {useEffect} from "react";
import Page from "../components/Page";
import Header from "./_Header";
import Button from "../components/Button";
import {useParams} from "react-router";
import ListSprites from "../components/List/ListSprites";
import {useDispatch, useSelector} from "react-redux";
import {setAtlas} from "../slices/atlasSlice";
import CardSprite from "../components/List/Cards/CardSprite";

const csrfToken = document.querySelector('meta[name="csrf-token"]').content;


const AtlasPage = () => {
    const {token} = useSelector(state => state.session);
    const dispatch = useDispatch();

    const atlasId = useParams().atlas_id
    const { atlas_id, title, atlas_img } = useSelector(state => state.atlas)

    useEffect(() => {
        fetch(`/atlas/${atlasId}/info`, {
            method: "GET",
            headers: {
                'X-CSRF-Token': csrfToken,
                Authorization: `Bearer ${token}`
            }
        })
        .then(res => res.json())
        .then(data => {
            if (data.errors || data.error) {
                throw new Error(data)
            }
            dispatch(setAtlas({
                atlas_id: data.atlas_id,
                title: data.title,
                atlas_img: data.atlas_img
            }))
        })
        .catch(err => console.log("Error in AtlasPage: " + err.error + err.errors))
    }, []);

    const onAtlasTitleChange = () => {

    }

    const onAtlasUpdate = (type) => {
        const formData = new FormData()
        formData.append("atlas_id", atlasId)
        formData.append("type", type)
        fetch("/atlas", {
            method: "PUT",
            body: formData,
            headers: {
                'X-CSRF-Token': csrfToken,
                Authorization: `Bearer ${token}`
            }
        }).then(res => res.json())
            .then(data => console.log(data))
    }

    return (
        <div className="font-unbounded min-h-screen bg-russian-violet">
            <Header />
            <Page title="texture atlas">
                <div className="-mt-10 flex justify-end">
                    <Button type="violet" >Export</Button>
                </div>

                <div className="mt-6 mb-11">
                    <div className="absolute bg-pink h-1 w-screen left-0 mt-5 "></div>
                    <p className=" absolute bg-light-gray border-pink border-4 text-black text-xl rounded-xl z-10 py-1.5 px-3">
                        {title}
                    </p>
                {/*    todo change to input text field and add atlas renaming*/}
                </div>
                <div className="bg-timberwolf rounded-xl border-pink border-dashed border-5 mt-24" >
                    <div className="m-5 aspect-3/1"
                         style={{
                             backgroundImage: `url(\"/images/transparent.png\")`,
                             backgroundSize: "cover",
                         }}
                    >
                        <img src={atlas_img} alt=""/>
                    </div>
                </div>
                <div>
                    <Button type="violet" onClick={() => onAtlasUpdate("inline")}>Update Inline</Button>
                    <Button type="violet" onClick={() => onAtlasUpdate("bookshelf")}>Update Bookshelf</Button>
                    <Button type="violet" onClick={() => onAtlasUpdate("skyline")}>Update Skyline</Button>
                {/*    todo красивое меню выбора типа атласа */}
                </div>

                <div className="mt-8">
                    <ListSprites title="IMAGES "/>
                </div>
            </Page>
        </div>
    );

}

export default AtlasPage

