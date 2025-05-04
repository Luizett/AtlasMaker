import React, {useEffect, useState} from "react";
import {useParams} from "react-router";
import {useDispatch, useSelector} from "react-redux";
import {setAtlas, updateAtlasImage} from "../slices/atlasSlice";

import Page from "../components/Page";
import Header from "./_Header";
import Button from "../components/Button";
import ListSprites from "../components/List/ListSprites";
import Spinner from "../components/Spinner";
import useFetch from "../services/useFetch";
import consumer from "../channels/consumer";

const AtlasPage = () => {
    const atlasId = useParams().atlas_id
    const { atlas_id, title, atlas_img } = useSelector(state => state.atlas)
    const [loading, setLoading] = useState(false)
    const [loadingPercent,setLoadingPercent] = useState("0");

    const dispatch = useDispatch();
    const {request} = useFetch()

    useEffect(() => {
        request(`/atlas/${atlasId}/info`, "GET")
            .then(data => {
                dispatch(setAtlas({
                    atlas_id: data.atlas_id,
                    title: data.title,
                    atlas_img: data.atlas_img
                }))
            })
            .catch(err => console.log("Error in AtlasPage: " + err.error + err.errors))
    }, []);

    const onAtlasTitleChange = () => {
// todo atlas title change
    }

    const onAtlasUpdate = (type) => {
        setLoading(true)
        const subscription = consumer.subscriptions.create(
            { channel: 'LoadingChannel', atlas_id: atlas_id },
            {
                connected: () => console.log('Connected to LoadingChannel'),
                disconnected: () => console.log('Disconnected from LoadingChannel'),
                received: (data) => {
                    console.log(data)
                    setLoadingPercent(data.percent)
                }
            }
        )

        let requestBody = new FormData()
        requestBody.append("atlas_id", atlasId)
        requestBody.append("type", type)

        request("/atlas", "PUT", requestBody)
            .then(data => {
                dispatch(updateAtlasImage(data.atlas_img))
                setLoading(false)
            })
            .catch(err => console.log(err.error + err.errors))
    }

    return (
        <div className="font-unbounded min-h-screen bg-russian-violet">
            <Header />
            <Page title="texture atlas">
                <div className="-mt-10 flex justify-end">
                    <Button type="violet" >Export</Button>
                </div>
                <div>{loadingPercent}</div>

                <div className="mt-6 mb-11">
                    <div className="absolute bg-pink h-1 w-screen left-0 mt-5 "></div>
                    <p className=" absolute bg-light-gray border-pink border-4 text-black text-xl rounded-xl z-10 py-1.5 px-3">
                        {title}
                    </p>
                {/*    todo change to input text field and add atlas renaming*/}
                </div>
                <div id="atlas-img" className="bg-timberwolf rounded-xl border-pink border-dashed border-5 mt-24" >
                    <div className="m-5 aspect-3/1"
                         style={{
                             backgroundImage: `url(\"/images/transparent.png\")`,
                             backgroundSize: "cover",
                         }}
                    >
                        { loading?
                            <Spinner />
                            :
                            <img src={atlas_img} alt=""/>
                        }
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

export default AtlasPage;
